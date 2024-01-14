export ADMIN_DN="cn=admin,dc=acme,dc=org"
export LDAP_HOST="ldaps://localhost:636"
# export LDAP_HOST="ldaps://openldap:636"
export USER_PW="student_password"
export ADMIN_PW="admin"

ldapadd -Z -H $LDAP_HOST -D $ADMIN_DN -w $ADMIN_PW -f ./users.ldif
ldapsearch -H $LDAP_HOST -x -b "ou=users,dc=acme,dc=org"  -D $ADMIN_DN -w $ADMIN_PW

echo "Testing connection with password"

ldapwhoami -x -D "uid=johnc,ou=users,dc=acme,dc=org" -w $USER_PW -H $LDAP_HOST
ldapwhoami -x -D "uid=mariax,ou=users,dc=acme,dc=org" -w $USER_PW -H $LDAP_HOST
ldapwhoami -x -D "uid=lutherk,ou=users,dc=acme,dc=org" -w $USER_PW -H $LDAP_HOST
ldapwhoami -x -D "uid=katherinel,ou=users,dc=acme,dc=org" -w $USER_PW -H $LDAP_HOST