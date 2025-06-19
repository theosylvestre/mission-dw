from airflow.config_templates.airflow_local_settings import DEFAULT_LOGGING_CONFIG
import os

BASE_LOG_FOLDER = os.environ.get("AIRFLOW__LOGGING__BASE_LOG_FOLDER", "/opt/airflow/logs")
REMOTE_LOG_FOLDER = os.environ.get("AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER", "s3://airflow-logs")
S3_LOG_CONN_ID = os.environ.get("AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID", "minio-bucket-logs-conn")

LOGGING_CONFIG = DEFAULT_LOGGING_CONFIG

# Ajout du handler S3
LOGGING_CONFIG["handlers"]["s3"] = {
    "class": "airflow.providers.amazon.aws.log.s3_task_handler.S3TaskHandler",
    "formatter": "airflow",
    "base_log_folder": BASE_LOG_FOLDER,
    "s3_log_folder": REMOTE_LOG_FOLDER,
    "filename_template": "{{ ti.dag_id }}/{{ ti.task_id }}/{{ ts }}/{{ try_number }}.log",
    "delete_local_copy": False,
    "s3_log_conn_id": S3_LOG_CONN_ID,
    "append": False,
}

# S'assurer que le logger existe
if "airflow.task" not in LOGGING_CONFIG["loggers"]:
    LOGGING_CONFIG["loggers"]["airflow.task"] = {}

# Associer le handler S3
LOGGING_CONFIG["loggers"]["airflow.task"]["handlers"] = ["s3"]
LOGGING_CONFIG["loggers"]["airflow.task"]["level"] = "INFO"
LOGGING_CONFIG["loggers"]["airflow.task"]["propagate"] = False
