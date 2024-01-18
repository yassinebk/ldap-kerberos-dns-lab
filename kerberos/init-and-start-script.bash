#!/bin/bash

if [ ! -f /kerberos_initialized ]; then

echo "==================================================================================="
echo "==== Kadmin and Realm ============================================================="
echo "==================================================================================="
KADMIN_PRINCIPAL_FULL=$KADMIN_PRINCIPAL@$REALM
echo "KADMIN_PRINCIPAL_FULL: $KADMIN_PRINCIPAL_FULL"
echo "REALM: $REALM"
echo ""

echo "==================================================================================="
echo "==== Creating REALM in LDAP and local ============================================="
echo "==================================================================================="
if [ ! -f /etc/krb5kdc/.k5.${REALM} ]; 
then
	MASTER_PASSWORD=$(tr -cd '[:alnum:]' < /dev/urandom | fold -w30 | head -n1)
	kdb5_ldap_util -D ${LDAP_KADMIND_DN} -w ${LDAP_KADMIND_DN_PASSWORD} -H ${LDAP_SERVER} -r ${REALM} create -subtrees ${LDAP_BASE_DN} -k ${ENCRYPTION_TYPE} -M "K/M" -P ${MASTER_PASSWORD} -s -containerref ${LDAP_KERBEROS_CONTAINER_DN} <<< ${LDAP_KERBEROS_CONTAINER_DN}
	echo ""
else
	echo "REALM ${REALM} is existed in LDAP and local"
	echo ""
fi

echo "==================================================================================="
echo "==== Create keyfile for auto enter in LDAP (/service.keyfile) ====================="
echo "==================================================================================="
echo "DN for write/read is ${LDAP_KADMIND_DN}"
kdb5_ldap_util -D ${LDAP_KADMIND_DN} -w ${LDAP_KADMIND_DN_PASSWORD} -H ${LDAP_SERVER} -r ${REALM} stashsrvpw -f /service.keyfile ${LDAP_KADMIND_DN} <<EOF
${LDAP_KADMIND_DN_PASSWORD}
${LDAP_KADMIND_DN_PASSWORD}
EOF
echo ""

echo "DN for read is ${LDAP_KDC_DN}"
kdb5_ldap_util -D ${LDAP_KADMIND_DN} -w ${LDAP_KADMIND_DN_PASSWORD} -H ${LDAP_SERVER} -r ${REALM} stashsrvpw -f /service.keyfile ${LDAP_KDC_DN} <<EOF
${LDAP_KDC_DN_PASSWORD}
${LDAP_KDC_DN_PASSWORD}
EOF
echo ""

echo "==================================================================================="
echo "==== /etc/krb5.conf ==============================================================="
echo "==================================================================================="
KDC_KADMIN_SERVER=$(hostname -f)
tee /etc/krb5.conf <<EOF
[kdcdefaults]
    kdc_ports = $PORTS
	kdc_tcp_ports = $PORTS
	kadmind_port = $KADMIN_PORT
[libdefaults]
	default_realm = $REALM
	dns_lookup_realm = false
	dns_lookup_kdc = false
	ticket_lifetime = 24h
	renew_lifetime = 7d
	forwardable = true
	spake_preauth_groups = edwards25519
[realms]
	$REALM = {
		kdc_ports = $PORTS
		kdc_tcp_ports = $PORTS
		kadmind_port = $KADMIN_PORT
		kdc = $KDC_KADMIN_SERVER
		admin_server = $KDC_KADMIN_SERVER
		default_domain = $KDC_KADMIN_SERVER
		database_module = openldap_ldapconf
	}
EOF
echo ""

echo "==================================================================================="
echo "==== /etc/krb5kdc/kdc.conf ========================================================"
echo "==================================================================================="
tee /etc/krb5kdc/kdc.conf <<EOF
[realms]
	$REALM = {
		max_life = 12h 0m 0s
		acl_file = /etc/krb5kdc/kadm5.acl
		max_renewable_life = 7d 0h 0m 0s
		master_key_type = aes256-cts
		supported_enctypes = $SUPPORTED_ENCRYPTION_TYPES
		default_principal_flags = +preauth
	}
[dbdefaults]
	ldap_kerberos_container_dn = $LDAP_KERBEROS_CONTAINER_DN
[dbmodules]
    openldap_ldapconf = {
		db_library = kldap

		# if either of these is false, then the ldap_kdc_dn needs to
		# have write access
		disable_last_success = true
		disable_lockout  = true

        # this object needs to have read rights on
        # the realm container, principal container and realm sub-trees
		ldap_kdc_dn = "$LDAP_KDC_DN"

        # this object needs to have read and write rights on
        # the realm container, principal container and realm sub-trees
		ldap_kadmind_dn = "$LDAP_KADMIND_DN"

        ldap_service_password_file = /service.keyfile
        ldap_servers = $LDAP_SERVER
		ldap_conns_per_server = 5
    }
[logging]
	default = STDERR
	kdc = STDERR
	admin_server = STDERR
EOF
echo ""

echo "==================================================================================="
echo "==== /etc/krb5kdc/kadm5.acl ======================================================="
echo "==================================================================================="
tee /etc/krb5kdc/kadm5.acl <<EOF
$KADMIN_PRINCIPAL_FULL *
EOF
echo ""

echo "==================================================================================="
echo "==== Change password $KADMIN_PRINCIPAL_FULL ============================================="
echo "==================================================================================="
kadmin.local -q "change_password -pw $LDAP_KADMIND_DN_PASSWORD $KADMIN_PRINCIPAL_FULL"
echo ""

echo "==================================================================================="
echo "==== Run the services ============================================================="
echo "==================================================================================="
# We want the container to keep running until we explicitly kill it.
# So the last command cannot immediately exit. See
#   https://docs.docker.com/engine/reference/run/#detached-vs-foreground
# for a better explanation.

touch /kerberos_initialized
fi

echo "==================================================================================="
echo "==== Start KDC ===================================================================="
echo "==================================================================================="

krb5kdc -P /krb5kdc.pid
kadmind -nofork
