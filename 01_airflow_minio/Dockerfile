FROM python:3.9-slim

ENV AIRFLOW_VERSION=3.0.2

ENV AIRFLOW_HOME=/opt/airflow
WORKDIR $AIRFLOW_HOME

COPY requirements.txt /opt/requirements.txt

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    default-libmysqlclient-dev \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    libsasl2-dev \
    gcc \
    && pip install --upgrade pip setuptools wheel \
    && pip install "apache-airflow==${AIRFLOW_VERSION}" \
    && pip install -r "/opt/requirements.txt" \
    && rm -rf /var/lib/apt/lists/*

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]