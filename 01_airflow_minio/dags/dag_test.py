from datetime import timedelta, datetime

from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.operators.python import PythonOperator

# Default arguments for tasks in this DAG
default_args = {
    'owner': 'Ranga',
    'start_date': datetime(2022, 3, 4),
    'retries': 3,
    'retry_delay': timedelta(minutes=5),
}

# Define the DAG object
with DAG(
    dag_id='hello_world_dag',
    default_args=default_args,
    description='Hello World DAG',
    schedule='* * * * *',  # every minute
    catchup=False,
    tags=['example', 'helloworld'],
) as dag:

    def print_hello():
        return 'Hello World!'

    start_task = EmptyOperator(task_id='start_task')
    hello_world_task = PythonOperator(task_id='hello_world_task', python_callable=print_hello)
    end_task = EmptyOperator(task_id='end_task')

    start_task >> hello_world_task >> end_task
