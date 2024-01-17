# ./Docker/Dockerfile
# Base image
FROM php:7-apache

# Enable Apache ldap auth module
RUN a2enmod authnz_ldap 

# Add LDAP rules to apache's conf-enabled dir 
# (we'll make this file step 3)

COPY ldap.conf /etc/apache2/sites-available/000-default.conf

COPY ldap_server.crt /opt/certs/ldap_server.crt

# Add debugging help if you need it (currently commented out)
RUN echo "LogLevel debug" >> /etc/apache2/apache2.conf

# Convenient working directory
WORKDIR /var/www/html/

# Copy the project files we need (we'll be creating this in step 3)
COPY ./index.php ./index.php
COPY ./secure.php ./secure.php
# COPY ./.htaccess ./.htaccess
RUN mkdir /certs
COPY ./ldap_server.crt /certs/ldap_server.crt
COPY ./ldap_server.key /certs/ldap_server.key