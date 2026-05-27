# chromeboxctl

`chromeboxctl` is the first controlled interface for AI-assisted management of the ChromeOS host.

It runs from the Mac and talks to the ChromeOS host through the local SSH alias:

```sh
ssh chromebox
```

## Commands

```sh
scripts/chromeboxctl doctor
scripts/chromeboxctl status
scripts/chromeboxctl health
scripts/chromeboxctl network
scripts/chromeboxctl storage
scripts/chromeboxctl hardware
scripts/chromeboxctl devmode
scripts/chromeboxctl vm
scripts/chromeboxctl snapshot
scripts/chromeboxctl snapshot --save
scripts/chromeboxctl restore-ssh
```

## Permission Model

Default command policy:

| Command | Risk | Writes to ChromeOS host? |
| --- | --- | --- |
| `doctor` | low | no |
| `status` | low | no |
| `health` | low | no |
| `network` | low | no |
| `storage` | low | no |
| `hardware` | low | no |
| `devmode` | low | no |
| `vm` | low | no |
| `snapshot` | low | no |
| `snapshot --save` | low | no, writes local `snapshots/` only |
| `restore-ssh` | medium | yes |

`restore-ssh` runs:

```sh
sudo /usr/local/bin/restore-ssh
```

It restores the local SSH server and firewall rule for the ChromeOS host. This is intentionally the only write action in v0.

## AI Operating Boundary

The AI agent may use read-only commands without extra confirmation when diagnosing the device.

The AI agent should ask before running:

- `restore-ssh`
- any command with `sudo`
- any command that changes firewall rules
- any command that modifies files outside this repository
- any command that opens the device to the public internet
- any command that deletes data

## Snapshot Workflow

Capture a local status report:

```sh
scripts/chromeboxctl snapshot --save
```

Snapshots may contain local IP addresses and process paths. Review before publishing outside the private repo.

## Connectivity Doctor

When the device is unreachable:

```sh
scripts/chromeboxctl doctor
```

This checks the local SSH alias, identity file, and whether the ChromeOS host can be reached. If SSH is down, wake the device and run this on the ChromeOS Developer Console:

```sh
sudo /usr/local/bin/restore-ssh
```
