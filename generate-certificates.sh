#!/bin/bash
set -e

# Création du dossier s'il n'existe pas
mkdir -p ./certs

# Nettoyage (optionnel, pour éviter les conflits)
rm -f ./certs/*

# -----------------------------------
# Certificats OpenLDAP
# -----------------------------------
cd ./certs

# Génération de la CA
openssl genrsa -out openldapCA.key 4096
openssl req -new -x509 -days 365 -key openldapCA.key -out openldapCA.crt -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=OpenLDAP-CA"

# Génération du certificat OpenLDAP
openssl genrsa -out openldap.key 4096
openssl req -new -key openldap.key -out openldap.csr -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=localhost"
openssl x509 -req -days 365 -in openldap.csr -CA openldapCA.crt -CAkey openldapCA.key -CAcreateserial -out openldap.crt
rm openldap.csr

# -----------------------------------
# Certificats phpLDAPadmin
# -----------------------------------

# Génération du certificat phpLDAPadmin
openssl genrsa -out phpldapadmin.key 4096
openssl req -new -key phpldapadmin.key -out phpldapadmin.csr -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=localhost"

# Création du fichier d'extension
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

# Signature du certificat phpLDAPadmin avec la CA (maintenant dans le même dossier)
openssl x509 -req -days 365 -in phpldapadmin.csr -CA openldapCA.crt -CAkey openldapCA.key -CAcreateserial -out phpldapadmin.crt -extensions v3_req -extfile phpldapadmin.ext

# Nettoyage des fichiers temporaires
rm phpldapadmin.csr phpldapadmin.ext

# -----------------------------------
# Permissions
# -----------------------------------
cd ../

# Application des permissions
chmod 600 ./certs/openldap.key ./certs/openldapCA.key ./certs/phpldapadmin.key
chmod 644 ./certs/openldap.crt ./certs/openldapCA.crt ./certs/phpldapadmin.crt

echo "Certificats générés dans ./certs"