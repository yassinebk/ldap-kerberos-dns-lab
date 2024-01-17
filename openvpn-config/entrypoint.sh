#! /bin/bash

ln -s /usr/share/easy-rsa/* /bin/easy-rsa

mkdir /etc/openvpn/auth
cp /ldap-auth.conf /etc/openvpn/auth/ldap.conf

echo "plugin /usr/lib64/openvpn/plugin/lib/openvpn-auth-ldap.so /etc/openvpn/auth/ldap.conf" >> /etc/openvpn/server/server.conf

service openvpn-server@server restart


cat easyrsa.vars >> /etc/openvpn/easy-rsa/2.0/vars
easyrsa init-pki
easyrsa gen-dh
easyrsa build-server-full vpnserver nopass
easyrsa build-ca

exec openvpn 