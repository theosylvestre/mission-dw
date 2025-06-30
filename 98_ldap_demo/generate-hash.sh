#!/bin/bash
read -s -p "Password: " password
echo

# Générer un salt binaire (4 bytes)
salt=$(openssl rand 4)

# Créer le hash SHA1 du mot de passe + salt
hash=$(echo -n "${password}" | cat - <(echo -n "${salt}") | openssl dgst -binary -sha1)

# Combiner hash + salt et encoder en base64
combined=$(echo -n "${hash}${salt}" | openssl base64 -A)

echo "{SSHA}${combined}"