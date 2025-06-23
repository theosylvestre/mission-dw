FROM apache/airflow:slim-3.0.2-python3.9

ENV AIRFLOW_HOME=/opt/airflow
WORKDIR $AIRFLOW_HOME

COPY requirements.txt /opt/requirements.txt
RUN pip install --no-cache-dir -r /opt/requirements.txt


# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential \
#     curl \
#     default-libmysqlclient-dev \
#     libssl-dev \
#     libffi-dev \
#     libpq-dev \
#     libsasl2-dev \
#     gcc \
#     mc \
#  && pip install --upgrade pip setuptools wheel \
#  && pip install --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-3.9.txt" \
#     "apache-airflow[celery,postgres]==${AIRFLOW_VERSION}" \
#  && pip install --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-3.9.txt" \
#     -r /opt/requirements.txt \
#  && curl -sSL https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc \
#  && chmod +x /usr/local/bin/mc \
#  && rm -rf /var/lib/apt/lists/* \
#  && useradd -ms /bin/bash airflow

COPY airflow-entrypoint.sh /airflow-entrypoint.sh
USER root
RUN chmod +x /airflow-entrypoint.sh
USER airflow

ENTRYPOINT ["/airflow-entrypoint.sh"]
