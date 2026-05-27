# AI-native OS Plan

This device is a good platform for an AI-native operating-system experiment because ChromeOS already separates the system into layers.

## Layer Model

```text
Mac / AI agent
  |
  | ssh chromebox
  v
ChromeOS host
  - device control plane
  - network and hardware inspection
  - VM/container management
  - recovery path
  |
  | vsh / ssh penguinbox
  v
Crostini Linux container
  - development workspace
  - package installs
  - services
  - experiments
```

## Principle

Give the AI strong capabilities, but only through narrow and inspectable interfaces.

Do not give the AI unconstrained root access as the default operating mode.

## v0 Capability Set

The first safe capability surface is `scripts/chromeboxctl`:

- inspect status
- inspect health
- inspect network
- inspect storage
- inspect hardware
- inspect Developer Mode state
- inspect Crostini VM/container state
- collect snapshots
- restore the SSH entry point when explicitly requested

## Future Capabilities

Candidate next additions:

- `chromeboxctl snapshot --save` to write timestamped reports
- `chromeboxctl container status` for Crostini details
- `chromeboxctl proxy status` for LAN proxy checks
- `chromeboxctl usb watch` for device attach/detach diagnostics
- `chromeboxctl issue` to create a GitHub issue from a snapshot

## Guardrails

High-risk actions should stay confirmation-gated:

- changing firewall rules
- installing packages on the ChromeOS host
- changing Developer Mode / firmware settings
- deleting data
- exposing SSH or services outside the LAN
- modifying account or credential state

Normal development belongs in the `penguin` Debian container.
