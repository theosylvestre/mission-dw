#!/bin/bash

set -euo pipefail

TEMPLATE_DIR="config_files/clickhouse/templates"
OUTPUT_DIR="config_files/clickhouse/etc/clickhouse-server/config.d"

# Vérifie que .env existe
if [[ ! -f .env ]]; then
  echo "❌ Fichier .env introuvable."
  exit 1
fi

# Charge les variables d'environnement
source .env

# Vérifie que gsed est installé
if ! command -v gsed &>/dev/null; then
  echo "❌ gsed (GNU sed) n'est pas installé. Installe-le via: brew install gnu-sed"
  exit 1
fi

# Vérifie les variables obligatoires
REQUIRED_VARS=(
  MINIO_CLICKHOUSE_BACKUP_BUCKET
  MINIO_ROOT_USER
  MINIO_ROOT_PASSWORD
  CLICKHOUSE_ADMIN_USER_PASSWORD
  CLICKHOUSE_BUSINESS_INTELLIGENCE_USER_PASSWORD
)

for VAR in "${REQUIRED_VARS[@]}"; do
  if [[ -z "${!VAR:-}" ]]; then
    echo "❌ La variable d'environnement $VAR est manquante."
    exit 1
  fi
done

echo "🚀 Génération des fichiers de configuration ClickHouse..."

# Génère storage.xml
gsed -e "s|\$MINIO_CLICKHOUSE_BACKUP_BUCKET|${MINIO_CLICKHOUSE_BACKUP_BUCKET}|g" \
     -e "s|\$MINIO_ACCESS_KEY_ID|${MINIO_ROOT_USER}|g" \
     -e "s|\$MINIO_SECRET_ACCESS_KEY|${MINIO_ROOT_PASSWORD}|g" \
     "$TEMPLATE_DIR/storage-template.xml" > "$OUTPUT_DIR/storage.xml"

# Génère users.xml
gsed -e "s|\$CLICKHOUSE_ADMIN_USER_PASSWORD|${CLICKHOUSE_ADMIN_USER_PASSWORD}|g" \
     -e "s|\$CLICKHOUSE_BUSINESS_INTELLIGENCE_USER_PASSWORD|${CLICKHOUSE_BUSINESS_INTELLIGENCE_USER_PASSWORD}|g" \
     "$TEMPLATE_DIR/users.xml" > "$OUTPUT_DIR/users.xml"

echo "✅ Fichiers générés avec succès dans : $OUTPUT_DIR"
