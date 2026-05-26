# Operating Model

This device has two useful layers.

## ChromeOS Host

Use for:

- SSH entry point
- hardware inspection
- ChromeOS networking
- VM/container management
- device recovery
- firmware and Developer Mode state checks

Avoid using the ChromeOS host for:

- normal package installs
- long-running application services
- random Linux experiments
- modifying the read-only root filesystem

ChromeOS is appliance-like. Treat it as the device control plane.

## Crostini Linux Container

Use `penguin` for:

- development tools
- Git repositories
- Python/Node/Rust/Go projects
- lightweight local web services
- experiments that need standard Debian packaging

This should be the main development layer.

Suggested baseline packages:

```sh
sudo apt update
sudo apt install -y git curl wget vim htop build-essential python3 python3-pip nodejs npm openssh-server
```

## Access Pattern

From the Mac:

```sh
ssh chromebox
```

Use this for host-level checks.

```sh
ssh penguinbox
```

Use this for development work.

## Reboot Recovery

After reboot, the host SSH listener and firewall rule may need to be restored from the device Developer Console:

```sh
sudo /usr/local/bin/restore-ssh
```

Then retry from the Mac:

```sh
ssh chromebox
```

## Security Notes

- Do not commit passwords.
- Do not commit private keys.
- Keep ChromeOS host changes minimal.
- Keep service development inside the Debian container.
- If this device needs internet-facing access later, use a deliberate tunnel plan instead of opening arbitrary LAN services.

