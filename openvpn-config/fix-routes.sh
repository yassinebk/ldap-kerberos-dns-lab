#!/bin/sh

echo "Adding default route to $route_vpn_gateway with /0 mask..."
ip route add default via ${ROUTE_VPN_GATEWAY}

echo "Removing /1 routes..."
ip route del 0.0.0.0/1 via ${ROUTE_VPN_GATEWAY}
ip route del 128.0.0.0/1 via ${ROUTE_VPN_GATEWAY}