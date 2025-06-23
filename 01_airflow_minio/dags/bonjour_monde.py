# hello_world_dag.py
"""
DAG Hello World - Exemple simple pour comprendre Airflow

Ce DAG illustre les concepts fondamentaux d'Airflow avec trois tâches
qui s'enchaînent pour former un workflow basique.
"""

from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.bash import BashOperator


# Fonctions Python qui seront appelées par nos tâches
def dire_bonjour():
    """
    Première tâche : afficher un message de bienvenue
    Cette fonction sera sérialisée et envoyée aux workers
    """
    print("🌟 Bonjour depuis Airflow !")
    print("Cette tâche s'exécute dans un Worker Celery")
    return "Message de bienvenue envoyé"


def traiter_donnees(**context):
    """
    Deuxième tâche : simulation d'un traitement de données
    
    Le paramètre **context permet d'accéder aux informations
    du contexte d'exécution (DAG run, task instance, etc.)
    """
    # Récupération du résultat de la tâche précédente via XCom
    message_precedent = context['task_instance'].xcom_pull(task_ids='dire_bonjour')
    print(f"📥 J'ai reçu : {message_precedent}")
    
    # Simulation d'un traitement
    print("⚙️ Traitement des données en cours...")
    donnees_traitees = {
        'timestamp': datetime.now().isoformat(),
        'statut': 'traitement_termine',
        'nb_lignes': 1000
    }
    
    print(f"✅ Données traitées : {donnees_traitees}")
    return donnees_traitees


def finaliser(**context):
    """
    Troisième tâche : finalisation du workflow
    """
    # Récupération des données de la tâche précédente
    resultats = context['task_instance'].xcom_pull(task_ids='traiter_donnees')
    print(f"📊 Résultats finaux : {resultats}")
    print("🎉 Workflow terminé avec succès !")


# Configuration par défaut pour toutes les tâches de ce DAG
default_args = {
    'owner': 'equipe_data',              # Propriétaire du DAG
    'depends_on_past': False,            # Pas de dépendance aux exécutions précédentes
    'email_on_failure': False,           # Pas d'email en cas d'échec
    'email_on_retry': False,             # Pas d'email lors des tentatives
    'retries': 2,                        # Nombre de tentatives en cas d'échec
    'retry_delay': timedelta(minutes=5), # Délai entre les tentatives
}

# Définition du DAG principal
dag = DAG(
    dag_id='hello_world_simple',         # Identifiant unique du DAG
    description='Mon premier DAG Airflow - Hello World',
    default_args=default_args,
    
    # Configuration de la planification
    schedule=timedelta(hours=1), # Exécution toutes les heures
    # Alternative avec cron : schedule_interval='0 * * * *'
    
    start_date=datetime(2024, 1, 1),     # Date de début du DAG
    catchup=False,                       # Ne pas rattraper les exécutions manquées
    
    # Configuration des tags pour l'organisation
    tags=['exemple', 'hello-world', 'debutant'],
    
    # Timeout global pour le DAG
    dagrun_timeout=timedelta(minutes=30),
)

# Définition des tâches
# ==================

# Tâche 1 : Dire bonjour (PythonOperator)
tache_bonjour = PythonOperator(
    task_id='dire_bonjour',              # Identifiant unique de la tâche
    python_callable=dire_bonjour,        # Fonction Python à exécuter
    dag=dag,                            # Référence au DAG parent
)

# Tâche 2 : Traitement (PythonOperator avec contexte)
tache_traitement = PythonOperator(
    task_id='traiter_donnees',
    python_callable=traiter_donnees,
    dag=dag,
)

# Tâche 3 : Commande système (BashOperator)
tache_systeme = BashOperator(
    task_id='info_systeme',
    bash_command="""
    echo "📋 Informations système :"
    echo "Date: $(date)"
    echo "Utilisateur: $(whoami)"
    echo "Répertoire: $(pwd)"
    echo "Processus Airflow: $(ps aux | grep airflow | wc -l) processus"
    """,
    dag=dag,
)

# Tâche 4 : Finalisation
tache_finalisation = PythonOperator(
    task_id='finaliser',
    python_callable=finaliser,
    dag=dag,
)

# Définition des dépendances (ordre d'exécution)
# =============================================

# Méthode 1 : Opérateur de dépendance >>
tache_bonjour >> tache_traitement

# Méthode 2 : Fonction set_downstream (équivalent)
tache_traitement.set_downstream(tache_systeme)

# Méthode 3 : Dépendances multiples avec une liste
[tache_traitement, tache_systeme] >> tache_finalisation