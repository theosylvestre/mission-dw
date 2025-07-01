FROM apache/airflow:slim-3.0.2-python3.9

ENV AIRFLOW_HOME=/opt/airflow
WORKDIR $AIRFLOW_HOME

USER root
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

USER airflow
COPY --chown=airflow:root requirements.txt /opt/requirements.txt
RUN pip install --upgrade pip setuptools wheel \
    && pip install --no-cache-dir -r /opt/requirements.txt

COPY --chown=airflow:root airflow-entrypoint.sh /airflow-entrypoint.sh
RUN chmod +x /airflow-entrypoint.sh

ENTRYPOINT ["/airflow-entrypoint.sh"]