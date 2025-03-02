#!/bin/bash
set -e

if [[ -z "$INTERFACES" ]]; then
    echo "No valid interfaces found..."
    INTERFACES=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')

    if [[ -n "$INTERFACES" ]]; then
        echo "Using primary interface: $INTERFACES"
    else
        echo "Error: No active network interface detected!"
        exit 1
    fi
else
    echo "Using interface: $INTERFACES"
fi

touch /var/lib/dhcp/dhcpd.leases

echo "Starting DHCP server on interface: $INTERFACES"

# Run DHCP server
exec /usr/sbin/dhcpd -f -4 -cf /etc/dhcp/dhcpd.conf $INTERFACES
