#!/bin/bash

# ============================================================
# Shell Executor SSH Key Setup
#
# Run this from the project root (where docker-compose.yml
# lives) before the first `docker compose up`.
#
# This script is idempotent:
#   - Existing keys are preserved.
#   - Missing keys are generated.
#   - authorized_keys is updated from the existing/generated
#     n8n runner public key.
#
# Keys:
#
#   n8n_runner_key
#       n8n -> shell-executor
#
#   executor_key
#       shell-executor -> external SSH services
#       (GitHub, GitLab, NAS, remote servers, etc.)
# ============================================================

set -euo pipefail

cd "$(dirname "$0")"

KEY_DIR="keys"

mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"


# ============================================================
# Helper
# ============================================================

generate_key() {
    local private_key="$1"
    local comment="$2"

    if [ -f "$private_key" ]; then
        echo "Already exists: $private_key"
        return
    fi

    echo "Generating: $private_key"

    ssh-keygen \
        -t ed25519 \
        -f "$private_key" \
        -N "" \
        -C "$comment"

    chmod 600 "$private_key"
    chmod 644 "${private_key}.pub"
}


# ============================================================
# 1. n8n -> shell-executor
# ============================================================

generate_key \
    "$KEY_DIR/n8n_runner_key" \
    "n8n-shell-executor-inbound"


# ============================================================
# 2. shell-executor -> external SSH services
# ============================================================

generate_key \
    "$KEY_DIR/executor_key" \
    "n8n-shell-executor-outbound"


# ============================================================
# 3. Configure authorized_keys
# ============================================================

if [ ! -f "$KEY_DIR/n8n_runner_key.pub" ]; then
    echo "ERROR: n8n runner public key is missing:" >&2
    echo "  $KEY_DIR/n8n_runner_key.pub" >&2
    exit 1
fi

PUBKEY=$(cat "$KEY_DIR/n8n_runner_key.pub")

cat > authorized_keys <<EOF
command="/usr/local/bin/allowed-commands.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ${PUBKEY}
EOF

chmod 600 authorized_keys


# ============================================================
# 4. Verify
# ============================================================

echo
echo "============================================================"
echo "SSH setup complete"
echo "============================================================"
echo

echo "n8n -> shell-executor"
echo "  Private key:"
echo "    $KEY_DIR/n8n_runner_key"
echo
echo "  Public key:"
echo "    $KEY_DIR/n8n_runner_key.pub"
echo
echo "  authorized_keys:"
echo "    authorized_keys"
echo

echo "shell-executor -> external services"
echo "  Private key:"
echo "    $KEY_DIR/executor_key"
echo
echo "  Public key:"
echo "    $KEY_DIR/executor_key.pub"
echo

echo "============================================================"
echo "Generated files"
echo "============================================================"
echo

ls -l "$KEY_DIR"

