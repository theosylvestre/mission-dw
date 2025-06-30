from flask_appbuilder.security.manager import AUTH_LDAP
from airflow.providers.fab.auth_manager.security_manager.override import FabAirflowSecurityManagerOverride
import os

# Configuration LDAP
AUTH_TYPE = AUTH_LDAP
AUTH_LDAP_SERVER = "ldap://openldap:1389"
AUTH_LDAP_BIND_USER = "cn=admin,dc=snef,dc=fr"
AUTH_LDAP_BIND_PASSWORD = "adminpass"
AUTH_LDAP_SEARCH = "ou=users,dc=snef,dc=fr"
AUTH_LDAP_SEARCH_FILTER = "objectClass=inetOrgPerson"
AUTH_LDAP_UID_FIELD = "mail"
AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
AUTH_LDAP_LASTNAME_FIELD = "sn"
AUTH_LDAP_EMAIL_FIELD = "mail"

# Configuration des utilisateurs
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = "Viewer"

# Mapping des groupes LDAP vers rôles Airflow
AUTH_ROLES_MAPPING = {
    "ROLE_DWH_DataEngineers_Prod": ["Op"],
    "ROLE_DWH_DataAnalysts_Prod": ["Viewer"], 
    "ROLE_DWH_DBAdmins": ["Admin"],
    "ROLE_DWH_Viewers": ["Viewer"]
}

# Synchronisation automatique des rôles
AUTH_ROLES_SYNC_AT_LOGIN = True

class CustomSecurityManager(FabAirflowSecurityManagerOverride):
    def __init__(self, appbuilder):
        super().__init__(appbuilder)
    
    def get_user_roles(self, user=None):
        """
        Récupère les rôles d'un utilisateur basé sur ses groupes LDAP
        """
        if user and hasattr(user, 'ldap_groups'):
            user_roles = []
            for ldap_group in user.ldap_groups:
                if ldap_group in AUTH_ROLES_MAPPING:
                    airflow_roles = AUTH_ROLES_MAPPING[ldap_group]
                    for role_name in airflow_roles:
                        role = self.find_role(role_name)
                        if role and role not in user_roles:
                            user_roles.append(role)
            return user_roles
        return []

# Utiliser le security manager personnalisé
SECURITY_MANAGER_CLASS = CustomSecurityManager

# Configuration supplémentaire
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None