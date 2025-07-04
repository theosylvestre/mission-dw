#!/bin/bash
set -e

echo "✅ Script airflow-entrypoint.sh exécuté"

connect_logs() {
  echo "🔗 Création de la connexion Airflow pour les logs S3 (MinIO)"
  if airflow connections get ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID} > /dev/null 2>&1; then
    echo "ℹ️ La connexion '${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID}' existe déjà, aucune action nécessaire."
  else
    echo "🆕 Création de la connexion '${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID}'"
    echo "🛠 airflow connections add ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID} --conn-type aws ..."
    
    # Debug des variables AVANT la création
    echo "🔍 DEBUG: DOCKER_MINIO_HOSTNAME=${DOCKER_MINIO_HOSTNAME}"
    echo "🔍 DEBUG: DOCKER_MINIO_INTERNAL_PORT=${DOCKER_MINIO_INTERNAL_PORT}"
    echo "🔍 DEBUG: URL qui sera utilisée: http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_INTERNAL_PORT}"
    
    airflow connections add ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID} \
      --conn-type 'aws' \
      --conn-extra "{
        \"aws_access_key_id\": \"${AWS_ACCESS_KEY_ID}\",
        \"aws_secret_access_key\": \"${AWS_SECRET_ACCESS_KEY}\",
        \"region_name\": \"us-east-1\",
        \"endpoint_url\": \"http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_INTERNAL_PORT}\"
      }"
    
    # Vérification APRÈS la création
    echo "🔍 Connexion créée - vérification:"
    airflow connections get ${AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID}
  fi
}

case "$1" in
  init)
    echo "🚀 Initialisation de la base Airflow"
    airflow db migrate
    connect_logs
    ;;

  scheduler)
    echo "✅ Lancement du scheduler d'Airflow"
    exec airflow "$@"
    ;;

  api-server)
    echo "✅ Lancement de l'API Server d'Airflow"
    exec airflow "$@"
    ;;

  triggerer)
    echo "✅ Lancement du triggerer d'Airflow"
    exec airflow "$@"
    ;;

  dag-processor)
    echo "✅ Lancement du Dag Processor d'Airflow"
    exec airflow "$@"
    ;;

  celery-worker)
    echo "✅ Lancement du worker Celery"
    exec airflow celery worker
    ;;

  *)
    echo "🔁 Commande personnalisée : $@"
    exec "$@"
    ;;
esac
