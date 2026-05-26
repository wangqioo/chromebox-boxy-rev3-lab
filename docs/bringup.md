# Bring-up Log

This is the setup path from a fresh ChromeOS device to remote access from a Mac.

## 1. Initial Constraint

The device needed internet access for Google/ChromeOS setup, but the home network did not provide direct access to required Google services.

USB was connected to the Mac, but it did not expose a useful control channel:

- no ADB device
- no serial console
- no USB network interface
- no mountable disk

Conclusion: use network access instead of USB for control.

## 2. Proxy Bootstrap

A LAN-accessible proxy was started on the Mac using the local Clash/Mihomo setup.

Observed LAN proxy endpoints on the Mac:

- HTTP proxy: `192.168.1.8:7899`
- SOCKS proxy: `192.168.1.8:7898`

The ChromeOS network proxy UI was configured manually to use the Mac as proxy. After that, ChromeOS was able to finish update and login.

Do not commit proxy credentials or subscription config to this repository.

## 3. ChromeOS Developer Mode

Developer Mode was enabled on the device. This allowed access to:

- crosh shell
- Developer Console
- `chronos` user
- `sudo` after setting a dev password

Developer Console login:

```text
localhost login: chronos
```

Set the `chronos` developer password on the device:

```sh
sudo chromeos-setdevpasswd
```

The actual password is not documented here.

## 4. Crostini Linux Container

The Linux development environment was created from ChromeOS Settings.

Observed container:

- VM: `termina`
- container: `penguin`
- Linux user: `wq15850752485`
- distro: Debian GNU/Linux 13 `trixie`
- container IPv4: `100.115.92.26`
- ChromeOS side of VM network: `100.115.92.25`

The container SSH service was enabled and initially reached from the Mac through a reverse tunnel.

## 5. ChromeOS Host SSH

The ChromeOS host already had OpenSSH server binaries:

```sh
/usr/sbin/sshd
/usr/bin/ssh-keygen
```

The root filesystem is read-only, so host SSH keys cannot be generated under `/etc/ssh`. Generate them under the writable stateful partition:

```sh
sudo mkdir -p /mnt/stateful_partition/etc/ssh
sudo ssh-keygen -A -f /mnt/stateful_partition
```

Validate and start `sshd` on a nonstandard port:

```sh
sudo /usr/sbin/sshd -t
sudo /usr/sbin/sshd -p 2223
```

Open ChromeOS host firewall for the port:

```sh
sudo iptables -I INPUT 1 -p tcp --dport 2223 -j ACCEPT
sudo ip6tables -I INPUT 1 -p tcp --dport 2223 -j ACCEPT
```

The Mac public key was added to `chronos`:

```sh
mkdir -p ~/.ssh
echo '<mac-public-key>' >> ~/.ssh/authorized_keys
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
```

The placeholder above is intentional. Do not store private keys or unnecessary user-identifying keys in the repo.

## 6. Mac SSH Aliases

Two local SSH aliases were added to the Mac's `~/.ssh/config`:

```sshconfig
Host chromebox
    HostName 192.168.1.45
    Port 2223
    User chronos
    IdentityFile ~/.ssh/id_ed25519
    ServerAliveInterval 30
    ServerAliveCountMax 3

Host penguinbox
    HostName 192.168.1.45
    Port 2223
    User chronos
    IdentityFile ~/.ssh/id_ed25519
    RequestTTY yes
    RemoteCommand export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/bin; exec /usr/bin/vsh --owner_id=<owner-id> --vm_name=termina --target_container=penguin --user=<linux-user> -- /bin/bash
    ServerAliveInterval 30
    ServerAliveCountMax 3
```

The actual local file was backed up before editing.

## 7. Recovery After Reboot

The manual `sshd` process and firewall rules may not survive reboot. A recovery script was installed on the ChromeOS host:

```text
/usr/local/bin/restore-ssh
```

After a ChromeOS reboot, use the Developer Console and run:

```sh
sudo /usr/local/bin/restore-ssh
```

Then remote access should work again:

```sh
ssh chromebox
ssh penguinbox
```

