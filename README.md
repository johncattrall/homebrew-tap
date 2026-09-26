# John Cattrall's Homebrew tap

## Home Assistant AirTag Importer

```sh
brew install johncattrall/tap/home-assistant-airtag-importer
home-assistant-airtag-importer --help
```

Apple Silicon macOS 14 or newer. The formula installs a versioned CLI binary and a
private Python 3.14 environment with pinned, checksummed wheels for Bluetooth
diagnostics; installation does not resolve or fetch packages from PyPI.

```sh
home-assistant-airtag-importer --output json --output-dir ./ha-imports
home-assistant-airtag-importer --diagnose --scan-seconds 30 ha-imports/*.findmy.json
brew upgrade johncattrall/tap/home-assistant-airtag-importer
```

Use `--save-alignment` only when you want verified primary-key observations saved
with private backups. No Home Assistant configuration is changed automatically.
Exports, state, and backups in your working directory are not removed on uninstall.

[Application source and documentation](https://github.com/johncattrall/home-assistant-airtag-importer)

[Versioned binaries and corresponding source](https://github.com/johncattrall/home-assistant-airtag-importer/releases)
