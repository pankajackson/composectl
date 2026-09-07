FROM debian:bookworm-slim

# ---- Add the CLI tools your workflows actually need here ----
# Example: RUN apt-get update && apt-get install -y --no-install-recommends ffmpeg imagemagick curl jq
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server \
    bash \
    git \
    curl \
    wget \
    jq \
    ca-certificates \
    openssh-client \
    rsync \
    unzip \
    zip \
    tar \
    gzip \
    coreutils \
    findutils \
    grep \
    sed \
    gawk \
    procps \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /var/run/sshd

RUN useradd -m -s /bin/bash n8n-runner \
    && mkdir -p /home/n8n-runner/.ssh \
    && chmod 700 /home/n8n-runner/.ssh \
    && chown n8n-runner:n8n-runner /home/n8n-runner/.ssh

# Hardened sshd config: key-only auth, no root login, custom port,
# host keys stored outside the image so they persist across rebuilds.
RUN sed -i \
    -e 's/^#\?PermitRootLogin.*/PermitRootLogin no/' \
    -e 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' \
    -e 's/^#\?KbdInteractiveAuthentication.*/KbdInteractiveAuthentication no/' \
    -e 's/^#\?ChallengeResponseAuthentication.*/ChallengeResponseAuthentication no/' \
    -e 's/^#\?PubkeyAuthentication.*/PubkeyAuthentication yes/' \
    -e 's/^#\?X11Forwarding.*/X11Forwarding no/' \
    -e 's/^#\?AllowTcpForwarding.*/AllowTcpForwarding no/' \
    -e 's/^#\?AllowAgentForwarding.*/AllowAgentForwarding no/' \
    -e 's/^#\?PermitTunnel.*/PermitTunnel no/' \
    -e 's/^#\?Port .*/Port 2222/' \
    /etc/ssh/sshd_config \
    && { \
        echo "HostKey /etc/ssh-host-keys/ssh_host_ed25519_key"; \
        echo "HostKey /etc/ssh-host-keys/ssh_host_rsa_key"; \
        echo "AllowUsers n8n-runner"; \
        echo "MaxAuthTries 3"; \
        echo "LoginGraceTime 20"; \
        echo "ClientAliveInterval 60"; \
        echo "ClientAliveCountMax 2"; \
    } >> /etc/ssh/sshd_config

# Allowlist of binaries that may be invoked over SSH, and the wrapper
# script that enforces it (see allowed-commands.sh / allowed-commands.txt).
COPY allowed-commands.sh /usr/local/bin/allowed-commands.sh
COPY allowed-commands.txt /etc/shell-executor/allowed-commands.txt
RUN chmod +x /usr/local/bin/allowed-commands.sh

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2222
ENTRYPOINT ["/entrypoint.sh"]
