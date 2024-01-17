FROM ubuntu:latest

RUN apt update && apt install -y openvpn easy-rsa gettext-base iptables ldap-utils  openvpn-auth-ldap

COPY ./ldap-ca.crt /certs/ldap-ca.crt
COPY certs/ /tmp/certs
COPY server.conf /etc/openvpn/server.conf
COPY ldap-auth.conf /etc/openvpn/auth/ldap-auth.conf

RUN chmod +x /usr/lib/openvpn/openvpn-auth-ldap.so
RUN mv /tmp/certs/* /certs/ 

RUN chmod 600 /certs/*
COPY openvpn-run.sh /opt/openvpn-run.sh
RUN chmod +x /opt/openvpn-run.sh

COPY ./fix-routes.sh /etc/openvpn/fix-routes.sh
RUN chmod o+x /etc/openvpn/fix-routes.sh 
RUN chown root:root /etc/openvpn/fix-routes.sh

COPY ./ldap.conf /etc/ldap.conf

RUN ls /certs

CMD "/opt/openvpn-run.sh"
# CMD sleep infinity 
