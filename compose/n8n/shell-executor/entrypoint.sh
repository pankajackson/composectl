#!/bin/bash
set -euo pipefail

# Copy the read-only mounted authorized_keys into place with the strict
# permissions sshd requires (a bind-mounted file often has the wrong
# owner/mode for this, so we normalize it on every start).
cp /home/n8n-runner/.ssh/authorized_keys.ro /home/n8n-runner/.ssh/authorized_keys
chown n8n-runner:n8n-runner /home/n8n-runner/.ssh/authorized_keys
# chmod 600 /home/n8n-runner/.ssh/authorized_keys

# Generate host keys once and persist them on the mounted volume, so the
# host key fingerprint stays stable across container restarts/rebuilds.
mkdir -p /etc/ssh-host-keys
if [ ! -f /etc/ssh-host-keys/ssh_host_ed25519_key ]; then
  ssh-keygen -t ed25519 -f /etc/ssh-host-keys/ssh_host_ed25519_key -N "" -q
fi
if [ ! -f /etc/ssh-host-keys/ssh_host_rsa_key ]; then
  ssh-keygen -t rsa -b 4096 -f /etc/ssh-host-keys/ssh_host_rsa_key -N "" -q
fi
chmod 600 /etc/ssh-host-keys/ssh_host_*_key

exec /usr/sbin/sshd -D -e
