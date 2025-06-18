#!/bin/bash
set -e

echo "✅ Script airflow-entrypoint.sh exécuté"


# Fonction de synchronisation des DAGs depuis MinIO
sync_dags() {
  echo "🔧 Configuration du client MinIO"
  mc alias set dagsbucket http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_PORT} \
    "${MINIO_BUCKET_ACCESS_KEY_ID}" "${MINIO_BUCKET_SECRET_ACCESS_KEY}"

  mkdir -p /opt/airflow/dags

  echo "📥 Synchronisation des DAGs depuis MinIO"
  mc mirror --watch --overwrite dagsbucket/${MINIO_DAGS_BUCKET} /opt/airflow/dags
}

case "$1" in
  init)
    echo "🚀 Initialisation de la base Airflow"
    sync_dags &
    airflow db migrate
    ;;

  scheduler)
    echo "✅ Lancement du scheduler d'Airflow : $@"
    sync_dags &
    exec airflow "$@"
    ;;

  api-server)
    echo "✅ Lancement de l'Api-Server d'Airflow : $@"
    sync_dags &
    exec airflow "$@"
    ;;

  triggerer)
    echo "✅ Lancement du triggerer d'Airflow: $@"
    sync_dags &
    exec airflow "$@"
    ;;

  dag-processor)
    echo "✅ Lancement du Dag Processor d'Airflow : $@"
    sync_dags &
    exec airflow "$@"
    ;;

  celery-worker)
    # Remplace celery-worker par la vraie commande 'celery worker'
    echo "✅ Lancement du worker Celery"
    sync_dags &
    exec airflow celery worker
    ;;

  *)
    echo "🔁 Commande personnalisée : $@"
    exec "$@"
    ;;
esac