# Aller dans le dossier certs
cd ./certs

# Génération de la clé privée de l'autorité de certification (CA)
openssl genrsa -out openldapCA.key 4096

# Création du certificat de l'autorité de certification
openssl req -new -x509 -days 365 -key openldapCA.key -out openldapCA.crt -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=OpenLDAP-CA"

# Génération de la clé privée du serveur OpenLDAP
openssl genrsa -out openldap.key 4096

# Création d'une demande de certificat pour le serveur
openssl req -new -key openldap.key -out openldap.csr -subj "/C=FR/ST=PACA/L=Marseille/O=Snef/OU=IT/CN=localhost"

# Signature du certificat du serveur avec l'autorité de certification
openssl x509 -req -days 365 -in openldap.csr -CA openldapCA.crt -CAkey openldapCA.key -CAcreateserial -out openldap.crt

# Nettoyage du fichier CSR temporaire
rm openldap.csr

# Ajustement des permissions
chmod 600 openldap.key openldapCA.key
chmod 644 openldap.crt openldapCA.crt