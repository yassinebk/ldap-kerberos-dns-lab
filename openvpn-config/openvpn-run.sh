#!/bin/bash
export OPENVPN=/etc/openvpn

mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi


ip -6 route show default 2>/dev/null
if [ $? = 0 ]; then
    echo "Checking IPv6 Forwarding"
    if [ "$(</proc/sys/net/ipv6/conf/all/disable_ipv6)" != "0" ]; then
        echo "Sysctl error for disable_ipv6, please run docker with '--sysctl net.ipv6.conf.all.disable_ipv6=0'"
    fi

    if [ "$(</proc/sys/net/ipv6/conf/default/forwarding)" != "1" ]; then
        echo "Sysctl error for default forwarding, please run docker with '--sysctl net.ipv6.conf.default.forwarding=1'"
    fi

    if [ "$(</proc/sys/net/ipv6/conf/all/forwarding)" != "1" ]; then
        echo "Sysctl error for all forwarding, please run docker with '--sysctl net.ipv6.conf.all.forwarding=1'"
    fi
fi


exec /usr/sbin/openvpn --cd $OPENVPN --script-security 2 --config $OPENVPN/server.conf