#!/bin/sh
set -e

echo "⏳ Attente de la disponibilité de MinIO..."

# Attente active avec mc alias set (réessaie tant que ça échoue)
until mc alias set local "http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_PORT}" "${MINIO_ROOT_USER}" "${MINIO_ROOT_PASSWORD}"; do
  echo "⏱️ MinIO pas encore prêt, nouvelle tentative dans 2s..."
  sleep 2
done

echo "✅ MinIO est accessible."

# Création des buckets
mc mb -p "local/${MINIO_DAGS_BUCKET}" || echo "ℹ️ Bucket ${MINIO_DAGS_BUCKET} déjà présent."
mc mb -p "local/${MINIO_LOGS_BUCKET}" || echo "ℹ️ Bucket ${MINIO_LOGS_BUCKET} déjà présent."

echo "✅ Buckets créés ou déjà existants. Fin du script."
