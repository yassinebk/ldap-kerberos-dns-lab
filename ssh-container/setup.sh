
echo 'Match group sshldapuser
  AuthorizedKeysCommand /opt/ldap-sshkey.sh %u
  AuthorizedKeysCommandUser nobody' >> /etc/ssh/sshd_config

rm /etc/pam_ldap.conf && ln -s /etc/ldap/ldap.conf /etc/pam_ldap.conf

sed -i.bak 's#compat#compat ldap#g' /etc/nsswitch.conf
service nscd restart
echo "session	 required	 pam_mkhomedir.so" >> /etc/pam.d/common-session
cp  /tmp/ldap_server.crt /etc/ssl/certs/ldapcacert.crt
mv /tmp/sssd.conf /etc/sssd/sssd.conf
mv /tmp/ldap.conf /etc/ldap/ldap.conf 

echo  "session required pam_oddjob_mkhomedir.so" >>"/etc/pam.d/system-auth"
chmod 600 /etc/sssd/sssd.conf
sleep 5
service sssd restart
service ssh restart

