#!/bin/sh
set -eu

PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/opt/bin
PORT="${1:-2223}"

sudo mkdir -p /mnt/stateful_partition/etc/ssh

if [ ! -f /mnt/stateful_partition/etc/ssh/ssh_host_ed25519_key ] || [ ! -f /mnt/stateful_partition/etc/ssh/ssh_host_rsa_key ]; then
  sudo ssh-keygen -A -f /mnt/stateful_partition
fi

if ! sudo netstat -ltnp 2>/dev/null | grep -q ":${PORT}"; then
  sudo /usr/sbin/sshd -p "${PORT}"
fi

sudo iptables -C INPUT -p tcp --dport "${PORT}" -j ACCEPT 2>/dev/null || sudo iptables -I INPUT 1 -p tcp --dport "${PORT}" -j ACCEPT
sudo ip6tables -C INPUT -p tcp --dport "${PORT}" -j ACCEPT 2>/dev/null || sudo ip6tables -I INPUT 1 -p tcp --dport "${PORT}" -j ACCEPT

sudo netstat -ltnp | grep ":${PORT}" || true
echo "chromebox ssh ready on port ${PORT}"

