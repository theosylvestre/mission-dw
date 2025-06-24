# Documentation de l'architecture d'airflow

## Points à prendre en considération

- Apache airflow 3.0, n'utilise plus webserver mais api-server et dag-processor : https://airflow.apache.org/docs/apache-airflow/stable/installation/upgrading_to_airflow3.html#step-7-changes-to-your-startup-scripts

- /usr/local/lib/python3.9/site-packages/airflow/configuration.py:858 DeprecationWarning: The secret_key option in [webserver] has been moved to the secret_key option in [api] - the old setting has been used, but please update your config.

