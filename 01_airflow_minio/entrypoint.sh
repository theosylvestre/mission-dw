#!/bin/bash
set -e

echo "Démarrage du conteneur Airflow"
airflow db migrate

# echo "Synchronisation des DAGs depuis le bucket MinIO"
# aws s3 sync s3://${MINIO_DAGS_BUCKET} /opt/airflow/dags \
#     --endpoint-url http://${DOCKER_MINIO_NAME}:9000

exec airflow "$@"