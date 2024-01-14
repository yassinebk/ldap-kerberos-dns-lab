export ADMIN_DN="cn=admin,dc=acme,dc=org"
export ADMIN_PW="admin"

ldapadd -Z -H ldaps://localhost:636 -D $ADMIN_DN -w $ADMIN_PW -f ./groups.ldif
ldapsearch -H ldaps://localhost:636 -x -b "ou=groups,dc=acme,dc=org"  -D $ADMIN_DN -w $ADMIN_PW
