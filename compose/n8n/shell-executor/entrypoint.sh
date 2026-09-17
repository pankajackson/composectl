#!/bin/bash
set -euo pipefail

# Prepare SSH directory
mkdir -p /home/n8n-runner/.ssh
chown n8n-runner:n8n-runner /home/n8n-runner/.ssh
chmod 700 /home/n8n-runner/.ssh

# Install inbound SSH key
cp /home/n8n-runner/.ssh/authorized_keys.ro \
   /home/n8n-runner/.ssh/authorized_keys
chown n8n-runner:n8n-runner /home/n8n-runner/.ssh/authorized_keys
chmod 600 /home/n8n-runner/.ssh/authorized_keys

# Install outbound SSH key
cp /run/secrets/executor_key.ro \
   /home/n8n-runner/.ssh/executor_key
chown n8n-runner:n8n-runner /home/n8n-runner/.ssh/executor_key
chmod 600 /home/n8n-runner/.ssh/executor_key

# Configure the default outbound SSH key
cat > /home/n8n-runner/.ssh/config <<'EOF'
Host *
    IdentityFile ~/.ssh/executor_key
    IdentitiesOnly yes
EOF

chown n8n-runner:n8n-runner /home/n8n-runner/.ssh/config
chmod 600 /home/n8n-runner/.ssh/config

# Generate persistent SSH host keys
mkdir -p /etc/ssh-host-keys
chmod 755 /etc/ssh-host-keys

if [ ! -f /etc/ssh-host-keys/ssh_host_ed25519_key ]; then
    ssh-keygen \
        -t ed25519 \
        -f /etc/ssh-host-keys/ssh_host_ed25519_key \
        -N "" \
        -q
fi

if [ ! -f /etc/ssh-host-keys/ssh_host_rsa_key ]; then
    ssh-keygen \
        -t rsa \
        -b 4096 \
        -f /etc/ssh-host-keys/ssh_host_rsa_key \
        -N "" \
        -q
fi

chmod 600 /etc/ssh-host-keys/ssh_host_*_key
chmod 644 /etc/ssh-host-keys/ssh_host_*_key.pub

# Start SSH server
exec /usr/sbin/sshd -D -e
