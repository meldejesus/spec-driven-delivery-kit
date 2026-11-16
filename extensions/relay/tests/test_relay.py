import contextlib
import sys
sys.dont_write_bytecode = True

import fcntl
import importlib.util
from pathlib import Path
import tempfile
import textwrap
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).parents[1] / 'templates/scripts/relay/relay.py'
spec = importlib.util.spec_from_file_location('relay', SCRIPT)
relay = importlib.util.module_from_spec(spec)
spec.loader.exec_module(relay)

THREAD = '''# Relay check
## Roles
| Role | Agent | Does |
| Writer | Codex | Writes |
| Reviewer | Claude | Reviews |
## Relay configuration
- Mode: tmux
- Writer tmux target: check:agents.1
- Reviewer tmux target: check:agents.2
## Codex (Writer) — check
Transport check only.
Next: Reviewer — acknowledge this entry
'''


class FakeTmux:
    def __init__(self, root):
        self.root = root
        self.draft = ''
        self.transcript = ''
        self.sends = []
        self.pid = '100'
        self.ignore_first_enter = False
        self.enters = 0
        self.on_enter = None

    def __call__(self, *args):
        if args[0] == 'display-message':
            return f'%1\t{self.pid}\t{self.root}\t2.1.322'
        if args[0] == 'capture-pane':
            draft = '\n  '.join(textwrap.wrap(self.draft, width=85))
            return f'{self.transcript}\n❯ {draft}\n──────────\n  bypass permissions on'
        if args[0] == 'send-keys' and '-l' in args:
            self.sends.append(args)
            self.draft = args[-1]
            return ''
        if args[0] == 'send-keys':
            self.enters += 1
            if self.ignore_first_enter and self.enters == 1:
                return ''
            self.transcript += '\n❯ ' + self.draft
            self.draft = ''
            if self.on_enter:
                self.on_enter()
            return ''
        raise AssertionError(args)


class RelayTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name).resolve()
        self.thread = self.root / 'thread.md'
        self.thread.write_text(THREAD)
        self.db = relay.connect(self.root)
        self.addCleanup(self.db.close)
        self.identifier = relay.enqueue(self.db, self.root, 'thread.md',
                                        'Codex (Writer) — check', 'Reviewer')
        self.fake = FakeTmux(self.root)
        self.addCleanup(patch.stopall)
        patch.object(relay, 'tmux', self.fake).start()
        patch.object(relay.time, 'sleep').start()

    def row(self):
        return self.db.execute('SELECT * FROM handoffs WHERE id=?',
                               (self.identifier,)).fetchone()

    def retry_now(self):
        with self.db:
            self.db.execute('UPDATE handoffs SET due=0')
        relay.tick(self.db, self.root)

    def test_duplicate_enqueue_and_persistence(self):
        again = relay.enqueue(self.db, self.root, 'thread.md',
                              'Codex (Writer) — check', 'Reviewer')
        self.assertEqual(again, self.identifier)
        with contextlib.closing(relay.connect(self.root)) as other:
            self.assertEqual(other.execute('SELECT count(*) FROM handoffs').fetchone()[0], 1)

    def test_occupied_input_retries_after_clear(self):
        self.fake.draft = 's'
        relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'pending')
        self.assertEqual(self.fake.draft, 's')
        self.assertEqual(self.fake.sends, [])
        self.fake.draft = ''
        self.retry_now()
        self.assertEqual(self.row()['state'], 'submitted')
        self.assertEqual(len(self.fake.sends), 1)

    def test_submitted_message_never_reinjected(self):
        relay.tick(self.db, self.root)
        relay.tick(self.db, self.root)
        self.assertEqual(len(self.fake.sends), 1)
        relay.acknowledge(self.db, self.identifier)
        relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'acknowledged')
        self.assertIsNotNone(self.row()['received'])
        self.assertEqual(len(self.fake.sends), 1)

    def test_second_enter_only_for_our_unsent_wrapped_draft(self):
        self.fake.ignore_first_enter = True
        relay.tick(self.db, self.root)
        self.assertEqual(self.fake.enters, 2)
        self.assertEqual(self.row()['state'], 'submitted')
        self.assertEqual(len(self.fake.sends), 1)

    def test_acknowledgement_race_is_preserved(self):
        self.fake.on_enter = lambda: relay.acknowledge(self.db, self.identifier)
        relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'acknowledged')

    def test_restart_during_injection_does_not_resend(self):
        relay.update(self.db, self.identifier, 'delivering')
        relay.worker(self.db, self.root, once=True)
        self.assertEqual(self.row()['state'], 'needs_attention')
        self.assertEqual(self.fake.sends, [])

    def test_only_one_worker(self):
        with (relay.runtime(self.root) / 'worker.lock').open('a') as lock:
            fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            relay.worker(self.db, self.root, once=True)
        self.assertEqual(self.row()['state'], 'pending')
        self.assertEqual(self.fake.sends, [])

    def test_changed_thread_supersedes_pending_work(self):
        self.thread.write_text(THREAD + '\n## User — later\nNext: User — wait\n')
        relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'superseded')
        self.assertEqual(self.fake.sends, [])

    def test_user_gate_cannot_be_enqueued(self):
        self.thread.write_text(THREAD.replace('Next: Reviewer', 'Next: User'))
        with self.assertRaises(ValueError):
            relay.enqueue(self.db, self.root, 'thread.md',
                          'Codex (Writer) — check', 'Reviewer')

    def test_target_must_stay_inside_workspace(self):
        self.fake.root = self.root.parent
        relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'pending')
        self.assertEqual(self.fake.sends, [])

    def test_replaced_session_is_not_targeted(self):
        self.fake.draft = 'a draft'
        relay.tick(self.db, self.root)
        self.fake.pid = '101'
        self.fake.draft = ''
        self.retry_now()
        self.assertEqual(self.row()['state'], 'needs_attention')
        self.assertEqual(self.fake.sends, [])

    def test_missing_pane_remains_queued(self):
        with patch.object(relay, 'pane_info', side_effect=OSError):
            relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'pending')
        self.assertEqual(self.fake.sends, [])

    def test_codex_empty_and_multiline_drafts(self):
        empty = 'Working\n› Ask Codex to do anything\n\n  GPT-6.1-Sol'
        self.assertEqual(relay.composer(empty, 'Codex'), '')
        self.assertEqual(relay.composer('› draft\n  continued\n\n  GPT-6.1-Sol', 'Codex'),
                         'draft\ncontinued')
        self.assertIsNone(relay.composer('shell $', 'Codex'))

    def test_overdue_receipt_flags_attention_without_resend(self):
        relay.tick(self.db, self.root)
        with self.db:
            self.db.execute('UPDATE handoffs SET submitted=0')
        relay.tick(self.db, self.root)
        self.assertEqual(self.row()['state'], 'needs_attention')
        self.assertEqual(len(self.fake.sends), 1)


if __name__ == '__main__':
    unittest.main()
