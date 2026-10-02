#!/bin/sh
set -eu

deny_file=/config/denylist.txt
[ -f "$deny_file" ] || exit 0

while IFS= read -r entry || [ -n "$entry" ]; do
  entry=${entry%%#*}
  entry=$(printf '%s' "$entry" | tr -d '[:space:]')
  [ -n "$entry" ] || continue

  # Accept only IP/CIDR characters before passing the value to iptables.
  case "$entry" in
    *[!0-9a-fA-F:./]*) echo "Skipping invalid denylist entry: $entry" >&2; continue ;;
  esac
  case "$entry" in
    *:*) firewall=ip6tables ;;
    *) firewall=iptables ;;
  esac

  if ! "$firewall" -w -C DOCKER-USER -s "$entry" -j DROP 2>/dev/null; then
    "$firewall" -w -I DOCKER-USER 1 -s "$entry" -j DROP
  fi
done < "$deny_file"
