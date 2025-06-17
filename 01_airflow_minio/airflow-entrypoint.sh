#!/bin/bash
set -e

echo "✅ Script airflow-entrypoint.sh exécuté"

# Fonction de synchronisation des DAGs depuis MinIO
sync_dags() {
  echo "🔧 Configuration du client MinIO"
  mc alias set minio http://${DOCKER_MINIO_HOSTNAME}:9000 \
    "${MINIO_BUCKET_ACCESS_KEY_ID}" "${MINIO_BUCKET_SECRET_ACCESS_KEY}"

  mkdir -p /opt/airflow/dags

  echo "📥 Synchronisation des DAGs depuis MinIO"
  mc cp --recursive minio/${MINIO_DAGS_BUCKET}/ /opt/airflow/dags || echo "⚠️ Bucket vide ou erreur"
}

case "$1" in
  init)
    echo "🚀 Initialisation de la base Airflow"
    airflow db migrate
    ;;

  scheduler|webserver|api-server|triggerer|dag-processor)
    # sync_dags
    echo "✅ Lancement d'Airflow : $@"
    exec airflow "$@"
    ;;

  celery-worker)
    # Remplace celery-worker par la vraie commande 'celery worker'
    echo "✅ Lancement du worker Celery"
    exec airflow celery worker
    ;;

  *)
    echo "🔁 Commande personnalisée : $@"
    exec "$@"
    ;;
esac