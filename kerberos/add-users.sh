#! /bin/bash
LDAP_DOMAIN_UPPER=ACME.ORG

user="alice@${LDAP_DOMAIN_UPPER}"
docker-compose exec -it kerberos kadmin.local -q "addprinc -randkey ${user}"

user="max@${LDAP_DOMAIN_UPPER}"
docker-compose exec -it kerberos kadmin.local -q "addprinc -randkey ${user}"

docker-compose exec -it kerberos kadmin.local -q "add_policy -minlength 8 -minclasses 2 -minlife 1hour -maxlife 1day passwordpolicy"
docker-compose exec -it kerberos kadmin.local -q "modprinc -policy passwordpolicy ${user}"

