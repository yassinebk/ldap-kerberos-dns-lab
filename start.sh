#! /bin/bash

docker-compose up -d
ldapmodify -x -D "cn=admin,cn=config" -w config -f ldifs/allow_anoynmous_read.ldif -H ldaps://localhost:636 
docker exec project-ssh-container-1 /bin/sh -c "service nscd restart "
docker exec project-ssh-container-1 /bin/sh -c "service sssd start"