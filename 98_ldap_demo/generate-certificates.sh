#!/bin/bash
set -e

# Création des dossiers s'ils n'existent pas
mkdir -p ./certs_ldap ./certs_phpldapadmin

# Nettoyage (optionnel, pour éviter les conflits)
rm -f ./certs_ldap/* ./certs_phpldapadmin/*

# -----------------------------------
# Certificats OpenLDAP
# -----------------------------------
cd ./certs_ldap

openssl genrsa -out openldapCA.key 4096
openssl req -new -x509 -days 365 -key openldapCA.key -out openldapCA.crt -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=OpenLDAP-CA"

openssl genrsa -out openldap.key 4096
openssl req -new -key openldap.key -out openldap.csr -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=localhost"
openssl x509 -req -days 365 -in openldap.csr -CA openldapCA.crt -CAkey openldapCA.key -CAcreateserial -out openldap.crt
rm openldap.csr

# -----------------------------------
# Certificats phpLDAPadmin
# -----------------------------------
cd ../certs_phpldapadmin

openssl genrsa -out phpldapadmin.key 4096
openssl req -new -key phpldapadmin.key -out phpldapadmin.csr -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=localhost"

cat > phpldapadmin.ext << EOF
[v3_req]
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = localhost
DNS.2 = phpldapadmin
IP.1 = 127.0.0.1
IP.2 = ::1
EOF

# On référence la CA avec le chemin relatif correct depuis ce dossier
openssl x509 -req -days 365 -in phpldapadmin.csr -CA ../certs_ldap/openldapCA.crt -CAkey ../certs_ldap/openldapCA.key -CAcreateserial -out phpldapadmin.crt -extensions v3_req -extfile phpldapadmin.ext

rm phpldapadmin.csr phpldapadmin.ext

# -----------------------------------
# Permissions
# -----------------------------------


cd ../
# ls

chmod 600 ./certs_ldap/openldap.key ./certs_ldap/openldapCA.key ./certs_phpldapadmin/phpldapadmin.key
chmod 644 ./certs_ldap/openldap.crt ./certs_ldap/openldapCA.crt ./certs_phpldapadmin/phpldapadmin.crt

echo "Certificats générés dans ./certs_ldap et ./certs_phpldapadmin"
