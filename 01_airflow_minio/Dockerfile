FROM apache/airflow:slim-3.0.2-python3.9

ENV AIRFLOW_HOME=/opt/airflow
WORKDIR $AIRFLOW_HOME

# Passer en root pour installer les dépendances système
USER root

# Installer les dépendances système nécessaires pour LDAP et autres outils
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    gcc \
    g++ \
    libldap2-dev \
    libsasl2-dev \
    libssl-dev \
    python3-dev \
    curl \
    default-libmysqlclient-dev \
    libffi-dev \
    libpq-dev \
    mc \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Repasser en utilisateur airflow
USER airflow

# Copier et installer les requirements Python
COPY --chown=airflow:root requirements.txt /opt/requirements.txt
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /opt/requirements.txt

# Copier et configurer l'entrypoint
COPY airflow-entrypoint.sh /airflow-entrypoint.sh

# Repasser en root pour les permissions de l'entrypoint
USER root
RUN chmod +x /airflow-entrypoint.sh

# Retour à l'utilisateur airflow pour l'exécution
USER airflow

ENTRYPOINT ["/airflow-entrypoint.sh"]