#! /bin/bash
echo "generating a keypair for $1"
openssl genrsa  -out "$1_private.pem"
openssl rsa -pubout -in "$1_private.pem" -out "$1_public.pem"

cat $1_public.pem


