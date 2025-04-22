FROM debian:12

RUN apt-get update && apt-get install -y isc-dhcp-server iproute2 && rm -rf /var/lib/apt/lists/*

# COPY dhcpd.conf /etc/dhcp/dhcpd.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

WORKDIR /var/lib/dhcp
EXPOSE 67/udp 68/udp

ENTRYPOINT ["/entrypoint.sh"]
