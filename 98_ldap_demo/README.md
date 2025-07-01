# Documentation du serveur OpenLDAP de demo

Ce serveur a pour vocation de simuler un serveur LDAP, qui pourra une fois la plateforme mis en production, implémenter plus rapidement l'annuaire LDAP de l'entreprise.

## Comment lancer le serveur OpenLDAP / PhpMyAdmin
Ce projet contient un Makefile, permettant l'exécution des commandes nécessaires au lancement de l'annuaire OpenLDAP et la page PhpMyAdmin, à la génération des certificats TLS, et des hash pour les utilisateurs.

### 1ère étape : générations des certificats
```
make generate-certificates
```

### 2nde étape : générations des hash pour les utilisateurs
```
make generate-hashs
```

### 3ème étape : lancement des services OpenLDAP / PhpMyAdmin
```sh
make start
```