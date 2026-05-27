# Chromebox Boxy Rev3 Lab

This repository documents and develops against a Google ChromeOS device identified as `boxy-rev3` / `dedede`.

The device was brought up from a fresh ChromeOS setup into:

- ChromeOS Developer Mode
- ChromeOS host SSH access over the LAN
- Crostini Linux container access
- A documented baseline inventory for future development

Sensitive values such as account passwords, Google account details, SSH private keys, and local proxy credentials are intentionally not stored here.

## Current Access

From the Mac that was used for setup:

```sh
ssh chromebox
```

Connects to the ChromeOS host as `chronos`.

```sh
ssh penguinbox
```

Connects through ChromeOS into the Crostini Linux container `penguin`.

The SSH aliases live in the Mac user's `~/.ssh/config`. They are not committed because they are machine-local.

## Device Snapshot

| Field | Value |
| --- | --- |
| ChromeOS device code | `boxy-rev3` |
| ChromeOS board | `dedede-signed-mp-v58keys` |
| Hardware ID | `BOXY-GLMX C3W-C2D-B3B-A6C-A9E` |
| Firmware ID | `Google_Boxy.13606.594.0` |
| CPU | Intel Celeron N4500, 2 cores |
| RAM | 7.6 GiB |
| Storage | 28.9 GB eMMC |
| Wi-Fi | Intel Wi-Fi 6 AX201 |
| Ethernet | Realtek RTL8111/8168/8211/8411 Gigabit Ethernet |
| GPU | Intel Jasper Lake UHD Graphics |
| ChromeOS version | `16640.40.0` |
| Chrome milestone | `148` |
| Channel | `stable-channel` |
| Kernel | `6.1.161-17590-gf0e6dabf73de` |
| Developer Mode | enabled |

## Repository Layout

```text
docs/
  bringup.md          End-to-end setup log from zero to SSH access
  device-inventory.md Hardware, OS, storage, network, and virtualization snapshot
  operating-model.md  How we should use ChromeOS host vs Linux container
scripts/
  chromeboxctl        Controlled Mac-side helper for ChromeOS host inspection
  restore-ssh.sh      ChromeOS-side SSH recovery script template
notes/
  next-steps.md       Suggested future work
snapshots/            Local diagnostic outputs, ignored by git
```

## Operating Rule

Use the ChromeOS host for device management and hardware inspection. Use the Linux container for normal development, package installs, services, and experiments.

## Controlled AI Interface

The first AI-safe control surface is:

```sh
scripts/chromeboxctl status
scripts/chromeboxctl snapshot
```

See [docs/chromeboxctl.md](docs/chromeboxctl.md) and [docs/ai-native-os-plan.md](docs/ai-native-os-plan.md).
