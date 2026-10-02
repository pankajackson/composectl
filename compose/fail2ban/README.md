# Fail2ban for Traefik

This service reads Traefik's JSON access log and bans clients with repeated
HTTP 401, 403, or 429 responses. Fail2ban runs with host networking and
`NET_ADMIN` so its rules can block traffic forwarded to Traefik's published
ports. The jail inserts its temporary ban chain in Docker's `DOCKER-USER`
chain.

## Lists and tuning

- Add trusted IP addresses to `config/allowlist.txt`, one per line.
  Comments beginning with `#` and blank lines are ignored. Entries are
  checked for each candidate ban by Fail2ban's `ignorecommand`. Allowlist
  edits take effect without a restart.
- Add addresses or CIDRs to `config/denylist.txt` for permanent drops in
  `DOCKER-USER`. These are loaded when the container starts; restart Fail2ban
  after editing. Removing an entry from the file does not remove an existing
  firewall rule; remove that rule manually from `DOCKER-USER`.
- Adjust `config/fail2ban/jail.local` to tune `bantime`, `findtime`, and
  `maxretry`. Add more jails there as needed.

The Traefik jail matches only 401, 403, and 429 responses to avoid treating
ordinary missing-page requests as attacks. Edit
`config/fail2ban/filter.d/traefik-auth.conf` if you need a different policy.

## Start up

Make sure the configured Docker bridge network exists and that Traefik and
Fail2ban are deployed from this repository's Compose files. Traefik writes
`compose/traefik/logs/access.log`; Fail2ban mounts that directory read-only.
Fail2ban uses host networking, so it does not join Traefik's proxy network or
need a Traefik router label.

The firewall integration depends on Docker's iptables-compatible
`DOCKER-USER` chain. Hosts using Docker's nftables firewall backend or a setup
without `DOCKER-USER` need a matching native firewall action before enabling
this jail.
