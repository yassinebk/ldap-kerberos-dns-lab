# Create Security group
FROM debian:bullseye-slim

ENV ADMIN_DN="cn=admin,dc=acme,dc=org"
ENV ADMIN_PW="admin"
ENV LDAP_HOST="ldaps://openldap:636"

# Install SSH server
RUN apt-get update && \
    apt-get install -y openssh-server libpam-ldap nscd ldap-utils sssd libpam-sss libnss-sss libnss-ldap vim && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir /var/run/sshd


COPY ./ldap_server.crt /tmp/ldap_server.crt
COPY ./ldap.conf /tmp/ldap.conf
COPY ./sssd.conf /tmp/sssd.conf

COPY setup.sh /tmp/setup.sh

COPY ./nsswitch.conf /tmp/nsswitch.conf

COPY ./ldap.secret /tmp/ldap.secret
COPY ./libnss-ldap.conf /tmp/libnss-ldap.conf
RUN chmod +x /tmp/setup.sh && /tmp/setup.sh

EXPOSE 22

# Start the SSH server
CMD ["/usr/sbin/sshd", "-D"]
