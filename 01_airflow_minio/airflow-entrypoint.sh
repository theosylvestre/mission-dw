#!/bin/bash
set -e

echo "✅ Script airflow-entrypoint.sh exécuté"

# Fonction de synchronisation des DAGs depuis MinIO
# sync_dags() {
#   echo "🔧 Configuration du client MinIO"
#   until mc alias set local "http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_PORT}" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}; do
#     echo "⏱️ MinIO pas encore prêt, nouvelle tentative dans 2s..."
#     sleep 2
#   done

#   mkdir -p /opt/airflow/dags

#   echo "📥 Synchronisation initiale des DAGs depuis MinIO"
#   mc mirror --overwrite --debug local/${MINIO_DAGS_BUCKET} /opt/airflow/dags

#   echo "🔁 Synchronisation récurrente toutes les 60s"
#   while true; do
#     sleep 60
#     echo "🔄 Resync DAGs depuis MinIO..."
#     mc mirror --overwrite local/${MINIO_DAGS_BUCKET} /opt/airflow/dags
#   done >> /tmp/dag_sync.log 2>&1 &
# }

# Fonction de création de la connexion pour les logs
connect_logs() {
  echo "🔗 Création de la connexion Airflow pour les logs S3 (MinIO)"

  if airflow connections get ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID} > /dev/null 2>&1; then
    echo "ℹ️ La connexion '${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID}' existe déjà, aucune action nécessaire."
  else
    echo "🆕 Création de la connexion '${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID}'"
    echo "🛠 airflow connections add ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID} --conn-type aws ..."
    airflow connections add ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID} \
      --conn-type 'aws' \
      --conn-extra "{
        \"aws_access_key_id\": \"${AWS_ACCESS_KEY_ID}\",
        \"aws_secret_access_key\": \"${AWS_SECRET_ACCESS_KEY}\",
        \"region_name\": \"us-east-1\",
        \"endpoint_url\": \"http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_PORT}\"
      }"
  fi
}

# Dispatch des rôles Airflow
case "$1" in
  init)
    echo "🚀 Initialisation de la base Airflow"
    # sync_dags
    airflow db migrate
    connect_logs
    ;;

  scheduler)
    echo "✅ Lancement du scheduler d'Airflow"
    # sync_dags
    # connect_logs
    exec airflow "$@"
    ;;

  api-server)
    echo "✅ Lancement de l'API Server d'Airflow"
    # sync_dags
    # connect_logs
    exec airflow "$@"
    ;;

  triggerer)
    echo "✅ Lancement du triggerer d'Airflow"
    # sync_dags
    # connect_logs
    exec airflow "$@"
    ;;

  dag-processor)
    echo "✅ Lancement du Dag Processor d'Airflow"
    # sync_dags
    # connect_logs
    exec airflow "$@"
    ;;

  celery-worker)
    echo "✅ Lancement du worker Celery"
    # sync_dags
    # connect_logs
    exec airflow celery worker
    ;;

  *)
    echo "🔁 Commande personnalisée : $@"
    exec "$@"
    ;;
esac
