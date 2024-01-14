
ldapwhoami -vvv -h ldap://openldap:389 -p 389 -D 'uid=ruan,ou=users,dc=acme,dc=org' -x -w "$PASSWORD"
