#!/bin/sh
set -e

echo "⏳ Attente de la disponibilité de MinIO..."

until mc alias set local "http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_PORT}" ${MINIO_ROOT_USER} ${MINIO_ROOT_PASSWORD};
 do
  echo "⏱️ MinIO pas encore prêt, nouvelle tentative dans 2s..."
  sleep 2
done

echo "✅ MinIO est accessible."

# Création des buckets
mc mb -p "local/${MINIO_DAGS_BUCKET}" || echo "ℹ️ Bucket ${MINIO_DAGS_BUCKET} déjà présent."
mc mb -p "local/${MINIO_LOGS_BUCKET}" || echo "ℹ️ Bucket ${MINIO_LOGS_BUCKET} déjà présent."

# Création utilisateur
mc admin user add local ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY} || echo "ℹ️ L'utilisateur ${AWS_ACCESS_KEY_ID} existe déjà."

# Création de la policy
cat <<EOF > /tmp/airflow-logs-policy.json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket",
        "s3:GetObjectVersion"
      ],
      "Resource": [
        "arn:aws:s3:::${MINIO_LOGS_BUCKET}",
        "arn:aws:s3:::${MINIO_LOGS_BUCKET}/*",
        "arn:aws:s3:::${MINIO_DAGS_BUCKET}",
        "arn:aws:s3:::${MINIO_DAGS_BUCKET}/*"
      ]
    }
  ]
}
EOF

# Ajout de la policy
mc admin policy create local airflow-logs-policy /tmp/airflow-logs-policy.json || echo "ℹ️ Policy déjà existante."
mc admin policy attach local airflow-logs-policy --user ${AWS_ACCESS_KEY_ID} || echo "ℹ️ Policy déjà attachée à ${AWS_ACCESS_KEY_ID}."

### 🔍 VÉRIFICATIONS ###

echo "🔍 Vérification de la présence des policies définies :"
mc admin policy list local | grep airflow-logs-policy && echo "✔️ Policy 'airflow-logs-policy' présente."

echo "🔍 Vérification des policies attachées à l'utilisateur '${AWS_ACCESS_KEY_ID}':"
mc admin user info local ${AWS_ACCESS_KEY_ID}

# Alias temporaire pour tester l'accès avec l'utilisateur Airflow
echo "🔐 Test d'accès en tant qu'utilisateur Airflow (${AWS_ACCESS_KEY_ID})..."
mc alias set ${AWS_ACCESS_KEY_ID} "http://${DOCKER_MINIO_HOSTNAME}:${DOCKER_MINIO_PORT}" ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}

echo "📁 Listing des buckets pour vérifier l'accès :"
mc ls ${AWS_ACCESS_KEY_ID}

echo "📂 Test de lecture/écriture dans ${MINIO_LOGS_BUCKET}..."
echo "hello-from-${AWS_ACCESS_KEY_ID}" | mc pipe "${AWS_ACCESS_KEY_ID}/${MINIO_LOGS_BUCKET}/access-test.txt" && echo "✔️ Écriture réussie"

echo "📄 Lecture de l'objet écrit :"
mc cat "${AWS_ACCESS_KEY_ID}/${MINIO_LOGS_BUCKET}/access-test.txt"

echo "✅ Vérification complète terminée. L'utilisateur Airflow a accès aux buckets nécessaires."
