# John Cattrall's Homebrew tap

## HAtag

```sh
brew install johncattrall/tap/hatag
hatag --help
```

Apple Silicon macOS 14 or newer. The formula installs a versioned CLI binary and a
private Python 3.14 environment with pinned, checksummed wheels for Bluetooth
diagnostics; installation does not resolve or fetch packages from PyPI.

```sh
hatag --output json --output-dir ./ha-imports
hatag --diagnose --scan-seconds 30 ha-imports/*.findmy.json
brew upgrade johncattrall/tap/hatag
```

Use `--save-alignment` only when you want verified primary-key observations saved
with private backups. No Home Assistant configuration is changed automatically.
Exports, state, and backups in your working directory are not removed on uninstall.

[Application source and documentation](https://github.com/johncattrall/hatag)

[Versioned binaries and corresponding source](https://github.com/johncattrall/hatag/releases)

Existing installs of `home-assistant-airtag-importer` migrate to `hatag` through
Homebrew's formula rename metadata. Update the tap and install/upgrade `hatag`;
no old executable alias is installed. Use `HATAG_PYTHON` instead of `FINDMY_PYTHON`
if you override the packaged diagnostic interpreter.
