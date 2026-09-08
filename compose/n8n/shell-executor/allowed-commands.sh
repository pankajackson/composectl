#!/bin/bash
# Forced command (see authorized_keys) — SSH_ORIGINAL_COMMAND holds
# whatever the client actually asked to run. Only the first token
# (the binary name) is checked against the allowlist; the whole
# command still runs through bash so arguments/pipes work normally
# for approved binaries.
set -euo pipefail

ALLOWLIST_FILE=/etc/shell-executor/allowed-commands.txt
CMD="${SSH_ORIGINAL_COMMAND:-}"


# A forced command intercepts SFTP subsystem requests too, but
# SSH_ORIGINAL_COMMAND is NOT set to the literal word "sftp" — it's
# set to whatever the "Subsystem sftp ..." line in sshd_config
# resolves to (Debian's default: /usr/lib/openssh/sftp-server), since
# that's what sshd looked up before substituting the forced command
# in its place. Match on that instead.
case "$CMD" in
  *sftp-server|internal-sftp)
    exec /usr/lib/openssh/sftp-server
    ;;
esac

if [ -z "$CMD" ]; then
  echo "No command supplied" >&2
  exit 1
fi

BINARY=$(echo "$CMD" | awk '{print $1}')

if ! grep -qxF "$BINARY" "$ALLOWLIST_FILE"; then
  echo "Command '$BINARY' is not in the allowlist" >&2
  exit 126
fi

exec bash -c "$CMD"
