# Nervus Integration

This directory contains the Chromebox-specific Nervus integration for this ChromeOS lab.

Keep this code here, not in `nervus-v1`, so the Nervus runtime remains generic and this repository owns the ChromeOS device behavior.

## What It Provides

`widgets/chromebox.py` defines a Nervus Arbor widget that wraps this repository's `scripts/chromeboxctl` helper.

Read-only commands:

- `status`
- `health`
- `snapshot`
- `network`
- `storage`
- `hardware`
- `devmode`
- `vm`

Confirmed recovery command:

- `restore-ssh`

## Install Into Nervus

From a Crostini shell where both repositories are checked out side by side:

```sh
cd ~/chromebox-boxy-rev3-lab
scripts/install-nervus-integration.sh ../nervus-v1
```

Then run Nervus:

```sh
cd ~/nervus-v1/core/arbor
export CHROMEBOX_CTL=../../../chromebox-boxy-rev3-lab/scripts/chromeboxctl
export CHROMEBOX_HOST=chromebox
python main.py
```

## API Shape

After installation, Arbor exposes:

```text
GET  /api/widgets/chromebox/state
GET  /api/widgets/chromebox/runs
GET  /api/widgets/chromebox/health
GET  /api/widgets/chromebox/snapshot
GET  /api/widgets/chromebox/network
GET  /api/widgets/chromebox/storage
GET  /api/widgets/chromebox/hardware
GET  /api/widgets/chromebox/devmode
GET  /api/widgets/chromebox/vm
POST /api/widgets/chromebox/restore-ssh
```

`restore-ssh` requires:

```json
{
  "confirm": "restore-ssh"
}
```

## Ownership Boundary

- `nervus-v1`: generic Agent OS runtime.
- `chromebox-boxy-rev3-lab`: ChromeOS-specific device control, docs, scripts, and Nervus integration.
