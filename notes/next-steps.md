# Next Steps

## Immediate

- Treat `scripts/chromeboxctl` as the first controlled AI interface.
- Use `docs/board-notes/README.md` as the shared map for ChromiumOS-like options beyond this specific Chromebox.
- Install baseline Debian packages in `penguin`.
- Keep ChromeOS host SSH recovery documented and minimal.

## Useful Development Directions

- Make `penguin` a lightweight internal development host.
- Add a small status dashboard for the device.
- Add scripts to collect hardware and ChromeOS health snapshots.
- Split broad board research into per-board notes when a target becomes active.
- Add a tunnel plan if the device needs remote access outside the LAN.
- Document any future firmware or Developer Mode changes.

## Open Questions

- Should this device stay on stable ChromeOS, or move to another channel later?
- Should remote access remain LAN-only, or use a controlled tunnel?
- Should development target Crostini only, or should a full alternate OS be evaluated?
