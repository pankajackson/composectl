#!/bin/bash
# Run this once from the project root (where docker-compose.yml lives)
# before first `docker compose up`. Re-run it (after deleting the old
# key) any time you want to rotate credentials.
set -euo pipefail

cd "$(dirname "$0")"
mkdir -p keys

if [ -f keys/n8n_runner_key ]; then
  echo "keys/n8n_runner_key already exists — delete it first if you want to rotate." >&2
  exit 1
fi

ssh-keygen -t ed25519 -f keys/n8n_runner_key -N "" -C "n8n-shell-executor"

PUBKEY=$(cat keys/n8n_runner_key.pub)

cat > authorized_keys <<EOF
command="/usr/local/bin/allowed-commands.sh",no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty ${PUBKEY}
EOF

echo
echo "Done."
echo "  Private key (paste into n8n's SSH credential): keys/n8n_runner_key"
echo "  authorized_keys written to shell-executor/authorized_keys"
echo
echo "keys/ contains a private key — keep it out of git (see .gitignore)."
