# snapcast-debian

One-line installer for [Snapcast](https://github.com/snapcast/snapcast) on Debian-based systems. Downloads the `.deb` with PipeWire support from GitHub releases and installs it.

## Install

### snapclient

```bash
curl -fsSL https://raw.githubusercontent.com/visualglitch91/snapcast-debian/main/install.sh | bash -s -- snapclient
```

### snapserver

```bash
curl -fsSL https://raw.githubusercontent.com/visualglitch91/snapcast-debian/main/install.sh | bash -s -- snapserver
```

### Specific version

Pass the version as the second argument to install a specific release instead of the latest:

```bash
curl -fsSL https://raw.githubusercontent.com/visualglitch91/snapcast-debian/main/install.sh | bash -s -- snapclient 0.34.0
```

## Supported platforms

- Architectures: `amd64`, `arm64`, `armhf` (whatever Snapcast publishes)
- Distros: Debian bookworm, bullseye, trixie.

## Local usage

```bash
chmod +x install.sh
./install.sh snapclient
./install.sh snapserver
./install.sh snapclient 0.34.0
```
