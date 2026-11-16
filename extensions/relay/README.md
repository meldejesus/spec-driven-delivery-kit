# Local relay extension

Install with `install/install-to-workspace.sh --target /path/to/workspace --with-relay`
(or `--all`). The runtime and instructions install to `scripts/relay/`.

See [operator instructions](templates/scripts/relay/README.md).

Run its focused checks from the kit root:

```bash
python3 -B -m unittest discover -s extensions/relay/tests -v
```

See [verification procedures](TESTING.md). Keep live run evidence in the installed workspace.
