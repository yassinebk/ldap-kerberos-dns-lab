#! /bin/bash


mkdir $1
cd $1

openssl genrsa -aes256 -out "$1.key" 4096
openssl rsa -in "$1.key" -out "$1.key"
openssl req -new -days 3650 -key $1.key -out $1.csr
openssl x509 -in ldap_server.csr -out $1.crt -req -signkey $1.key -days 3650
