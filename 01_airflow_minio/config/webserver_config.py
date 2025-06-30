from flask_appbuilder.security.manager import AUTH_LDAP
from airflow.providers.fab.auth_manager.security_manager.override import FabAirflowSecurityManagerOverride
import ldap
import os

# Configuration LDAP
AUTH_TYPE = AUTH_LDAP
AUTH_LDAP_SERVER = "ldap://host.docker.internal:1389"
AUTH_LDAP_BIND_USER = "cn=admin,dc=snef,dc=fr"
AUTH_LDAP_BIND_PASSWORD = "adminpass"
AUTH_LDAP_SEARCH = "ou=users,dc=snef,dc=fr"
AUTH_LDAP_SEARCH_FILTER = "(objectClass=inetOrgPerson)"
AUTH_LDAP_UID_FIELD = "cn"
AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
AUTH_LDAP_LASTNAME_FIELD = "sn"
AUTH_LDAP_EMAIL_FIELD = "mail"

# Configuration des utilisateurs
AUTH_USER_REGISTRATION = True
AUTH_USER_REGISTRATION_ROLE = None  # Pas de rôle par défaut

# Mapping des groupes LDAP vers rôles Airflow
AUTH_ROLES_MAPPING = {
    "cn=ROLE_DWH_DataEngineers_Prod,ou=roles,dc=snef,dc=fr": ["Admin"],
    "cn=ROLE_DWH_DataAnalysts_Prod,ou=roles,dc=snef,dc=fr": ["Viewer"],
    "cn=ROLE_DWH_DBAdmins,ou=roles,dc=snef,dc=fr": ["Admin"],
    "cn=ROLE_DWH_Viewers,ou=roles,dc=snef,dc=fr": ["Viewer"]
}

# Synchronisation automatique des rôles
AUTH_ROLES_SYNC_AT_LOGIN = True

class CustomSecurityManager(FabAirflowSecurityManagerOverride):
    def __init__(self, appbuilder):
        super().__init__(appbuilder)
    
    def auth_user_ldap(self, username, password):
        """
        Authentification LDAP avec récupération des groupes
        """
        print(f"DEBUG: Attempting LDAP auth for user: {username}")
        
        # Authentification de base
        user = super().auth_user_ldap(username, password)
        
        if user:
            print(f"DEBUG: User {username} authenticated successfully")
            
            # Récupérer les groupes LDAP de l'utilisateur
            ldap_groups = self.get_user_ldap_groups(username)
            print(f"DEBUG: Retrieved LDAP groups: {ldap_groups}")
            
            # Mapper les groupes LDAP vers les rôles Airflow
            airflow_roles = self.map_ldap_groups_to_roles(ldap_groups)
            print(f"DEBUG: Mapped Airflow roles: {[r.name for r in airflow_roles]}")
            
            # Assigner les rôles à l'utilisateur
            if airflow_roles:
                user.roles = airflow_roles
                self.get_session.commit()
                print(f"DEBUG: Roles assigned to user {username}: {[r.name for r in user.roles]}")
            else:
                print(f"DEBUG: No roles found for user {username}")
                
        return user
    
    def get_user_ldap_groups(self, username):
        """
        Récupère les groupes LDAP d'un utilisateur
        """
        try:
            # Connexion LDAP
            conn = ldap.initialize(AUTH_LDAP_SERVER)
            conn.simple_bind_s(AUTH_LDAP_BIND_USER, AUTH_LDAP_BIND_PASSWORD)
            
            # Recherche de l'utilisateur
            user_filter = f"(&(objectClass=inetOrgPerson)({AUTH_LDAP_UID_FIELD}={username}))"
            user_result = conn.search_s(
                AUTH_LDAP_SEARCH,
                ldap.SCOPE_SUBTREE,
                user_filter,
                ['memberOf', 'isMemberOf']  # Attributs de groupe possibles
            )
            
            groups = []
            if user_result:
                user_attrs = user_result[0][1]
                print(f"DEBUG: User LDAP attributes: {user_attrs}")
                
                # Essayer différents attributs de groupe
                for group_attr in ['memberOf', 'isMemberOf']:
                    if group_attr in user_attrs:
                        group_dns = [g.decode('utf-8') for g in user_attrs[group_attr]]
                        groups.extend(group_dns)
                        break
                
                # Si pas de memberOf, chercher dans les groupes directement
                if not groups:
                    groups = self.search_user_in_groups(conn, username)
            
            conn.unbind()
            return groups
            
        except Exception as e:
            print(f"ERROR: Failed to retrieve LDAP groups for {username}: {e}")
            return []
    
    def search_user_in_groups(self, conn, username):
        """
        Cherche l'utilisateur dans les groupes (si memberOf n'existe pas)
        """
        try:
            groups = []
            group_filter = f"(&(objectClass=groupOfNames)(member=cn={username},ou=users,dc=snef,dc=fr))"
            group_results = conn.search_s(
                "ou=roles,dc=snef,dc=fr",
                ldap.SCOPE_SUBTREE,
                group_filter,
                ['cn']
            )
            
            for group_dn, group_attrs in group_results:
                if group_dn:
                    groups.append(group_dn)
                    
            return groups
            
        except Exception as e:
            print(f"ERROR: Failed to search user in groups: {e}")
            return []
    
    def map_ldap_groups_to_roles(self, ldap_groups):
        """
        Mappe les groupes LDAP vers les rôles Airflow
        """
        airflow_roles = []
        
        for ldap_group in ldap_groups:
            print(f"DEBUG: Checking group: {ldap_group}")
            if ldap_group in AUTH_ROLES_MAPPING:
                print(f"DEBUG: Group found in mapping: {ldap_group}")
                role_names = AUTH_ROLES_MAPPING[ldap_group]
                for role_name in role_names:
                    role = self.find_role(role_name)
                    if role and role not in airflow_roles:
                        airflow_roles.append(role)
                        print(f"DEBUG: Role added: {role_name}")
            else:
                print(f"DEBUG: Group NOT found in mapping: {ldap_group}")
        
        return airflow_roles

# Utiliser le security manager personnalisé
SECURITY_MANAGER_CLASS = CustomSecurityManager

# Configuration supplémentaire
WTF_CSRF_ENABLED = True
WTF_CSRF_TIME_LIMIT = None