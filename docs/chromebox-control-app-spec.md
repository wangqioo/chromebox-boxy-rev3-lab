# Chromebox Control App Spec

`chromebox-control` is the Nervus app that turns the Boxy Rev3 Chromebox into an AI-native device without giving the AI unrestricted host access.

The app runs in Crostini and talks to the ChromeOS host through `scripts/chromeboxctl`.

## Purpose

- Expose ChromeOS host state to Nervus.
- Convert snapshots into structured events.
- Provide a narrow recovery action for SSH restoration.
- Keep host control auditable and confirmation-gated.

## Process Model

```text
Nervus Arbor
  |
  | HTTP
  v
app-chromebox-control in Crostini
  |
  | subprocess
  v
scripts/chromeboxctl
  |
  | SSH
  v
ChromeOS host as chronos
```

The app should not shell into arbitrary commands. It may call only known `chromeboxctl` commands.

## API

### Read-only

`GET /health`

Returns app health and last successful command time.

`GET /status`

Runs `chromeboxctl status`.

`GET /health/chromeos`

Runs `chromeboxctl health`.

`GET /snapshot`

Runs `chromeboxctl snapshot` and returns both raw Markdown and parsed summary fields when possible.

`GET /network`

Runs `chromeboxctl network`.

`GET /storage`

Runs `chromeboxctl storage`.

`GET /hardware`

Runs `chromeboxctl hardware`.

`GET /devmode`

Runs `chromeboxctl devmode`.

`GET /vm`

Runs `chromeboxctl vm`.

### Confirmation-gated

`POST /restore-ssh`

Runs `chromeboxctl restore-ssh`.

Required request body:

```json
{
  "confirm": "restore-ssh",
  "reason": "ChromeOS rebooted and host SSH is down"
}
```

Reject the request unless `confirm` exactly matches `restore-ssh`.

## Events

The app should publish Nervus events after each snapshot or health check.

Subjects:

- `system.chromeos.health`
- `system.chromeos.snapshot`
- `system.chromeos.network`
- `system.chromeos.storage`
- `system.chromeos.crostini`
- `system.chromeos.ssh`

Example event:

```json
{
  "source_app": "chromebox-control",
  "device": "boxy-rev3",
  "state": "warn",
  "kind": "storage",
  "summary": "stateful partition 86% used",
  "snapshot_id": "20260527-220100"
}
```

## Parsing Rules

The first version can keep raw Markdown. Add structured parsing only for stable fields:

- ChromeOS release
- kernel
- uptime
- memory available
- root filesystem usage
- stateful partition usage
- Developer Mode state
- `sshd` port status
- Crostini VM detected or missing

Do not make fragile UI decisions from free-form text that may change.

## Timeouts

Recommended command timeouts:

| Command | Timeout |
| --- | --- |
| `status` | 10 seconds |
| `health` | 15 seconds |
| `network` | 15 seconds |
| `storage` | 15 seconds |
| `hardware` | 20 seconds |
| `devmode` | 10 seconds |
| `vm` | 15 seconds |
| `snapshot` | 60 seconds |
| `restore-ssh` | 30 seconds |

Return a useful timeout error instead of leaving the request hanging.

## Security Rules

Allowed:

- call fixed `chromeboxctl` subcommands
- read command output
- write app-local cache or event records
- publish events to Nervus

Disallowed:

- accepting arbitrary shell command strings
- accepting arbitrary SSH hosts from requests
- writing to the ChromeOS host except `restore-ssh`
- storing private keys or passwords
- exposing this app to the public internet without auth

## App Registration

Suggested registration:

```json
{
  "id": "chromebox-control",
  "name": "Chromebox Control",
  "version": "0.1.0",
  "description": "Read-only ChromeOS host inspection and confirmed SSH recovery",
  "base_url": "http://app-chromebox-control:8016",
  "health_url": "http://app-chromebox-control:8016/health",
  "capabilities": [
    "chromeos.status",
    "chromeos.snapshot",
    "chromeos.health",
    "chromeos.recovery.confirmed"
  ]
}
```

## First Implementation

Implement the first version as a small FastAPI app:

- port `8016`
- one subprocess wrapper with command allowlist
- raw Markdown response support
- simple health cache
- optional NATS event publisher
- no write endpoint except confirmed `restore-ssh`

Keep the implementation boring. The value is the boundary, not complex code.
