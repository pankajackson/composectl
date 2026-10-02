#!/bin/sh
# Fail2ban ignorecommand: exit successfully when the candidate IP appears in allowlist.txt.
candidate="$1"
[ -n "$candidate" ] || exit 1

awk -v candidate="$candidate" '
  /^[[:space:]]*#/ || /^[[:space:]]*$/ { next }
  {
    gsub(/[[:space:]]/, "", $0)
    if ($0 == candidate) found = 1
  }
  END { exit(found ? 0 : 1) }
' /config/allowlist.txt
