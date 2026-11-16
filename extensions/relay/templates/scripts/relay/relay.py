#!/usr/bin/env python3
"""Durable, receipt-tracked tmux handoffs. Python standard library only."""
import argparse
import contextlib
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import shlex
import sqlite3
import subprocess
import sys
import time

TERMINAL = {'acknowledged', 'cancelled', 'superseded', 'needs_attention'}


def workspace_path(value):
    root = Path(value).resolve(strict=True)
    if not root.is_dir():
        raise ValueError('Workspace must be a directory')
    return root


def runtime(root):
    folder = root / 'workflow/.relay'
    folder.mkdir(mode=0o700, parents=True, exist_ok=True)
    return folder


def connect(root):
    db = sqlite3.connect(runtime(root) / 'queue.sqlite3', timeout=10)
    db.row_factory = sqlite3.Row
    db.execute('PRAGMA journal_mode=WAL')
    db.execute('PRAGMA synchronous=FULL')
    db.executescript('''
      CREATE TABLE IF NOT EXISTS handoffs (
        id TEXT PRIMARY KEY, thread TEXT NOT NULL, entry TEXT NOT NULL,
        source_hash TEXT NOT NULL, role TEXT NOT NULL, agent TEXT NOT NULL,
        target TEXT NOT NULL, message TEXT NOT NULL,
        state TEXT NOT NULL DEFAULT 'pending', reason TEXT NOT NULL DEFAULT '',
        pane TEXT, pane_pid TEXT, attempts INTEGER NOT NULL DEFAULT 0,
        due REAL NOT NULL DEFAULT 0, submitted REAL, received REAL,
        created REAL NOT NULL
      );
      CREATE TABLE IF NOT EXISTS control (key TEXT PRIMARY KEY, value TEXT);
    ''')
    return db


def enclosed(root, value):
    path = Path(value)
    if not path.is_absolute():
        path = root / path
    path = path.resolve(strict=True)
    path.relative_to(root)
    return path


def entries(text):
    return [part for part in re.split(r'(?=^## )', text, flags=re.M) if part.strip()]


def source_entry(text, heading):
    matches = [part for part in entries(text) if part.splitlines()[0] == heading]
    if len(matches) != 1:
        raise ValueError('Source entry heading must exist exactly once')
    return matches[0]


def next_role(body):
    found = re.findall(r'^Next:\s*(Writer|Reviewer|User)\b', body, re.M)
    return found[-1] if found else None


def role_config(text, role):
    mode = re.search(r'^- Mode: (\S+)', text, re.M)
    target = re.search(rf'^- {role} tmux target: (.+)$', text, re.M)
    agent = re.search(rf'^\| {role} \| ([^|]+) \|', text, re.M)
    if not mode or mode[1] != 'tmux' or not target or not agent:
        raise ValueError('Thread needs tmux mode and configured role/target')
    name = agent[1].strip()
    if name not in ('Codex', 'Claude'):
        raise ValueError('Only Codex and Claude composer profiles are supported')
    return target[1].strip(), name


def digest(value):
    return hashlib.sha256(value.encode()).hexdigest()


def handoff_message(root, path, heading, role, agent, identifier, text):
    script = root / 'scripts/relay/relay.py'
    ack = shlex.join(['python3', str(script), '--workspace', str(root),
                      'ack', '--id', identifier])
    known = re.search(rf'^## {agent} \({role}\)', text, re.M)
    setup = 'Kickoff guidance is already loaded; do not reread it.'
    if not known:
        setup = f'Read {root}/.github/skills/team-kickoff/SKILL.md for this session.'
    return (f'Relay handoff {identifier}. Acknowledge receipt first by running `{ack}`. '
            f'Continue as {role}. Read the entry {heading!r} in {path} and follow '
            f'its Next instruction. {setup} Acknowledge the source heading in '
            'your next normal thread entry. If this handoff ID was already '
            'handled, do not repeat the work. Queue your next agent handoff '
            'through scripts/relay/relay.py, not direct send-keys; never dispatch Next: User.')


def enqueue(db, root, thread, heading, role):
    path = enclosed(root, thread)
    text = path.read_text()
    heading = heading if heading.startswith('## ') else '## ' + heading
    body = source_entry(text, heading)
    if next_role(body) != role or entries(text)[-1] != body:
        raise ValueError('Only the latest entry addressed to this agent may be queued')
    target, agent = role_config(text, role)
    source_hash = digest(body)
    identifier = digest(f'{path}\n{heading}\n{role}\n{source_hash}')[:24]
    message = handoff_message(root, path, heading, role, agent, identifier, text)
    with db:
        db.execute('''INSERT OR IGNORE INTO handoffs
          (id,thread,entry,source_hash,role,agent,target,message,created)
          VALUES (?,?,?,?,?,?,?,?,?)''',
          (identifier, str(path), heading, source_hash, role, agent, target,
           message, time.time()))
    return identifier


def tmux(*args):
    result = subprocess.run(['tmux', *args], capture_output=True, text=True,
                            timeout=10, check=True)
    return result.stdout.rstrip('\n')


def pane_info(target):
    output = tmux('display-message', '-p', '-t', target,
                  '#{pane_id}\t#{pane_pid}\t#{pane_current_path}\t#{pane_current_command}')
    pane, pid, cwd, command = output.split('\t', 3)
    return {'pane': pane, 'pid': pid, 'cwd': cwd, 'command': command}


def composer(screen, agent):
    marker = '›' if agent == 'Codex' else '❯'
    lines = screen.splitlines()
    indexes = [i for i, line in enumerate(lines) if line.startswith(marker)]
    if not indexes:
        return None
    start = indexes[-1]
    text = lines[start][1:].strip()
    if agent == 'Codex' and text == 'Ask Codex to do anything':
        text = ''
    following = []
    for line in lines[start + 1:]:
        if re.match(r'^\s*[─━]{3,}|^\s+GPT-|^\s+gpt-', line):
            break
        following.append(line.strip())
    return '\n'.join([text, *following]).strip()


def agent_session(info, screen, agent):
    command = info['command'].lower()
    if agent == 'Codex':
        return 'codex' in command and composer(screen, agent) is not None
    valid = 'claude' in command or re.fullmatch(r'\d+\.\d+\.\d+', command)
    return bool(valid) and composer(screen, agent) is not None


def source_current(row, root):
    path = enclosed(root, row['thread'])
    text = path.read_text()
    body = source_entry(text, row['entry'])
    target, agent = role_config(text, row['role'])
    return (digest(body) == row['source_hash'] and entries(text)[-1] == body
            and next_role(body) == row['role'] and target == row['target']
            and agent == row['agent'])


def update(db, identifier, state, reason='', **fields):
    assignments = ['state=?', 'reason=?'] + [f'{key}=?' for key in fields]
    values = [state, reason, *fields.values(), identifier]
    with db:
        db.execute(f"UPDATE handoffs SET {','.join(assignments)} WHERE id=? "
                   "AND state NOT IN ('acknowledged','cancelled')", values)


def defer(db, row, reason):
    attempt = row['attempts'] + 1
    delay = min(30, 2 ** min(attempt, 5))
    update(db, row['id'], 'pending', reason, attempts=attempt, due=time.time()+delay)


def inspect_target(root, row):
    info = pane_info(row['target'])
    Path(info['cwd']).resolve(strict=True).relative_to(root)
    screen = tmux('capture-pane', '-p', '-t', info['pane'], '-S', '-60')
    return info, screen


def submitted(screen, row):
    # The ID must have left the composer and appear in the visible transcript
    # or the app's explicit queued-message area.
    draft = composer(screen, row['agent'])
    return row['id'] in re.sub(r'\s+', '', screen) and draft == ''


def dispatch(db, root, row):
    try:
        if not source_current(row, root):
            update(db, row['id'], 'superseded', 'Thread advanced or routing changed')
            return
        info, screen = inspect_target(root, row)
    except (ValueError, OSError, subprocess.SubprocessError):
        defer(db, row, 'Target or source unavailable; retrying')
        return
    if row['pane'] and (info['pane'], info['pid']) != (row['pane'], row['pane_pid']):
        update(db, row['id'], 'needs_attention', 'Target session replaced; no resend')
        return
    if not row['pane']:
        update(db, row['id'], 'pending', pane=info['pane'], pane_pid=info['pid'])
    if not agent_session(info, screen, row['agent']):
        defer(db, row, 'Expected agent UI not recognized')
        return
    if composer(screen, row['agent']) != '':
        defer(db, row, 'Composer occupied; draft preserved')
        return
    send_to_pane(db, root, row, info)


def send_to_pane(db, root, row, info):
    # Recheck immediately before injecting. Tmux cannot make human typing and
    # this check atomic; ambiguous submission is never retried automatically.
    latest = pane_info(info['pane'])
    if latest != info:
        defer(db, row, 'Target changed during inspection')
        return
    screen = tmux('capture-pane', '-p', '-t', info['pane'], '-S', '-60')
    if composer(screen, row['agent']) != '':
        defer(db, row, 'Composer changed; draft preserved')
        return
    update(db, row['id'], 'delivering', 'Submission in progress',
           pane=info['pane'], pane_pid=info['pid'])
    try:
        tmux('send-keys', '-l', '-t', info['pane'], '--', row['message'])
        time.sleep(0.3)
        tmux('send-keys', '-t', info['pane'], 'Enter')
        verify_submission(db, row, info)
    except (OSError, subprocess.SubprocessError):
        update(db, row['id'], 'needs_attention', 'Submission uncertain; no automatic resend')


def verify_submission(db, row, info):
    time.sleep(0.5)
    screen = tmux('capture-pane', '-p', '-t', info['pane'], '-S', '-60')
    draft = composer(screen, row['agent'])
    if draft is not None and re.sub(r'\s+', '', draft) == re.sub(r'\s+', '', row['message']):
        tmux('send-keys', '-t', info['pane'], 'Enter')
        time.sleep(0.5)
        screen = tmux('capture-pane', '-p', '-t', info['pane'], '-S', '-60')
    if submitted(screen, row):
        update(db, row['id'], 'submitted', 'Accepted/queued; awaiting receipt',
               submitted=time.time())
        return
    update(db, row['id'], 'needs_attention', 'No clear submission evidence; no automatic resend')


def tick(db, root):
    pending = db.execute("SELECT * FROM handoffs WHERE state='pending' AND due<=? "
                         'ORDER BY created', (time.time(),)).fetchall()
    occupied = {r[0] for r in db.execute(
        "SELECT target FROM handoffs WHERE state IN ('delivering','submitted','needs_attention')")}
    for row in pending:
        if row['target'] in occupied:
            continue
        try:
            dispatch(db, root, row)
        except Exception:
            # Preserve uncertainty even for unexpected worker failures.
            fresh = db.execute('SELECT state FROM handoffs WHERE id=?', (row['id'],)).fetchone()
            if fresh[0] == 'delivering':
                update(db, row['id'], 'needs_attention', 'Worker error during submission')
            else:
                defer(db, row, 'Inspection error; retrying')
        state = db.execute('SELECT state FROM handoffs WHERE id=?', (row['id'],)).fetchone()[0]
        if state in ('delivering', 'submitted', 'needs_attention'):
            occupied.add(row['target'])
    with db:
        db.execute("UPDATE handoffs SET state='needs_attention', reason='Receipt overdue; no automatic resend' "
                   "WHERE state='submitted' AND submitted<?", (time.time()-300,))


def worker(db, root, once=False):
    with (runtime(root)/'worker.lock').open('a') as lock:
        try:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        except BlockingIOError:
            return
        with db:
            db.execute("UPDATE handoffs SET state='needs_attention',reason='Worker restarted during submission; inspect before recovery' WHERE state='delivering'")
        while True:
            stop = db.execute("SELECT value FROM control WHERE key='stop'").fetchone()
            if stop and stop[0] == '1':
                return
            tick(db, root)
            if once:
                return
            time.sleep(1)


def start(db, root):
    with db:
        db.execute("INSERT OR REPLACE INTO control VALUES ('stop','0')")
    with (runtime(root)/'worker.log').open('a') as log:
        subprocess.Popen([sys.executable, str(Path(__file__).resolve()),
                          '--workspace', str(root), 'worker'], stdin=subprocess.DEVNULL,
                         stdout=log, stderr=log, start_new_session=True, close_fds=True)


def acknowledge(db, identifier):
    row = db.execute('SELECT state FROM handoffs WHERE id=?', (identifier,)).fetchone()
    if not row or row[0] in ('pending', 'cancelled', 'superseded'):
        raise ValueError('Cannot acknowledge an unknown or unsubmitted handoff')
    with db:
        db.execute("UPDATE handoffs SET state='acknowledged',reason='Recipient confirmed receipt',received=? WHERE id=?",
                   (time.time(), identifier))


def parser():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--workspace', required=True)
    sub = p.add_subparsers(dest='command', required=True)
    enq = sub.add_parser('enqueue')
    enq.add_argument('--thread', required=True)
    enq.add_argument('--entry', required=True)
    enq.add_argument('--role', choices=['Writer', 'Reviewer'], required=True)
    enq.add_argument('--no-start', action='store_true', help=argparse.SUPPRESS)
    sub.add_parser('start')
    sub.add_parser('stop')
    sub.add_parser('status')
    work = sub.add_parser('worker')
    work.add_argument('--once', action='store_true')
    for name in ('ack', 'cancel'):
        item = sub.add_parser(name)
        item.add_argument('--id', required=True)
    return p


def execute(args, db, root):
    if args.command == 'enqueue':
        identifier = enqueue(db, root, args.thread, args.entry, args.role)
        if not args.no_start:
            start(db, root)
        print(identifier)
        return
    if args.command == 'start':
        start(db, root)
    elif args.command == 'stop':
        with db:
            db.execute("INSERT OR REPLACE INTO control VALUES ('stop','1')")
    elif args.command == 'worker':
        worker(db, root, args.once)
    elif args.command == 'ack':
        acknowledge(db, args.id)
    elif args.command == 'cancel':
        row = db.execute('SELECT state FROM handoffs WHERE id=?', (args.id,)).fetchone()
        if not row or row[0] not in ('pending', 'needs_attention'):
            raise ValueError('Only pending or needs_attention messages can be cancelled; this cannot unsend input')
        update(db, args.id, 'cancelled', 'Cancelled explicitly by operator')
    elif args.command == 'status':
        rows = db.execute('SELECT id,role,target,state,reason,attempts FROM handoffs ORDER BY created').fetchall()
        print(json.dumps([dict(row) for row in rows], indent=2))


def main():
    os.umask(0o077)
    args = parser().parse_args()
    try:
        root = workspace_path(args.workspace)
        with contextlib.closing(connect(root)) as db:
            execute(args, db, root)
    except (ValueError, OSError, sqlite3.Error) as error:
        print(f'Relay error: {error}', file=sys.stderr)
        return 1
    return 0


if __name__ == '__main__':
    sys.exit(main())
