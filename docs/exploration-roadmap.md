# Exploration Roadmap

This roadmap turns the Boxy Rev3 Chromebox into a controlled ChromeOS / ChromiumOS lab.

The default rule is simple: inspect from the ChromeOS host, build inside the Crostini Debian container, and keep risky host changes explicit.

## Phase 0: Baseline

Goal: always know what state the device is in before changing anything.

- Capture a fresh host snapshot with `scripts/chromeboxctl snapshot`.
- Save snapshots under `snapshots/` and review before publishing.
- Track ChromeOS release, kernel, storage use, Developer Mode state, and Crostini state.
- Record reboots, channel changes, firmware changes, and failed experiments in `notes/`.

Good first questions:

- Did the ChromeOS update change the kernel or milestone?
- Did Developer Mode and host SSH survive reboot?
- Is the Crostini VM running cleanly?
- Is `/mnt/stateful_partition` filling up?

## Phase 1: Crostini Development Layer

Goal: make `penguin` the normal place to build and run tools.

Use Crostini for:

- Git repositories
- Python, Node, Rust, Go, and shell tools
- local dashboards and web services
- lightweight automation
- experiments that need Debian packages

Baseline package set:

```sh
sudo apt update
sudo apt install -y git curl wget vim htop build-essential python3 python3-pip nodejs npm openssh-server
```

Useful experiments:

- Run a local web dashboard from `penguin`.
- Test whether ChromeOS can open `penguin` services from the browser.
- Measure CPU, memory, and disk behavior under small workloads.
- Document any Crostini limitations around USB, networking, graphics, and background services.

## Phase 2: Device Control Plane

Goal: keep host-level control narrow, readable, and recoverable.

Extend `scripts/chromeboxctl` only when the command has a clear purpose and risk level.

Good additions:

- `snapshot --save` for timestamped local reports.
- `container status` for Crostini VM/container details.
- `proxy status` for LAN proxy detection.
- `usb` for USB attach and device inventory.
- `issue` for turning a snapshot into a GitHub issue draft.

Keep confirmation gates around:

- firewall changes
- `sudo` actions
- host file modifications
- package installs on the ChromeOS host
- Developer Mode or firmware changes
- public internet exposure

## Phase 3: Status Dashboard

Goal: make the current device state visible without SSH spelunking.

Start with a small read-only dashboard fed by snapshots or controlled commands. The preferred long-term shell is a lightweight Nervus deployment in Crostini; see [nervus-on-chromeos-plan.md](nervus-on-chromeos-plan.md).

Useful panels:

- ChromeOS version, channel, kernel, and uptime
- Developer Mode and firmware slot
- storage use for root, stateful, and encrypted stateful
- memory and swap
- Wi-Fi, Ethernet, and Crostini VM network
- Crostini process and service status
- last snapshot time and health summary

Keep the first dashboard local-only. Run it inside `penguin`; let ChromeOS browser view it over the Crostini forwarded port.

## Phase 4: Remote Access Plan

Goal: make off-LAN access deliberate instead of accidental.

Preferred shape:

- ChromeOS host SSH stays LAN-only.
- Crostini hosts development services.
- A tunnel is created only when needed.
- Tunnel endpoints, auth, and exposed ports are documented.

Candidate approaches:

- Tailscale or similar private mesh VPN.
- Cloudflare Tunnel for a specific web service.
- SSH reverse tunnel from `penguin` to a controlled VPS.

Avoid:

- exposing host SSH directly to the public internet
- opening broad firewall rules
- running random long-lived services on the ChromeOS host

## Phase 5: Hardware and OS Boundaries

Goal: understand what ChromeOS exposes and where it becomes inconvenient.

Explore carefully:

- PCI, USB, Bluetooth, Wi-Fi, Ethernet, audio, and GPU visibility
- Crostini access to USB devices
- power, suspend, reboot, and recovery behavior
- stateful partition layout
- `crossystem` Developer Mode and firmware state
- update behavior across ChromeOS milestones

Do not treat this phase as permission to modify firmware. Firmware and boot changes should get a separate plan first.

## Phase 6: Board Research Loop

Goal: use the real Chromebox lab to inform broader ChromiumOS board work.

Use [board notes](board-notes/README.md) for route selection:

- ChromeOS devices stay on official ChromeOS first.
- Old x86 PCs should check ChromeOS Flex first.
- Raspberry Pi uses FydeOS, openFyde, or Chromium OS for Raspberry Pi.
- RK3566/RK3568 follows experimental openFyde `rk356x` leads.
- RK3576 should be treated as a porting project until a mature public image exists.

When a board becomes active, split it into a focused note:

```text
docs/boards/<board-name>.md
```

Use the template from `docs/board-notes/README.md`.

## First Offline Tasks

These can be done before the machine is reachable from the current network:

1. Add `snapshot --save` to `scripts/chromeboxctl`.
2. Create the Nervus Lite compose profile in `nervus-v1`.
3. Implement the `chromebox-control` Nervus app from [chromebox-control-app-spec.md](chromebox-control-app-spec.md).
4. Add `docs/remote-access-plan.md`.
5. Build a tiny dashboard prototype that can read saved snapshot files.
6. Add a `snapshots/README.md` explaining what is safe to commit and what stays local.
