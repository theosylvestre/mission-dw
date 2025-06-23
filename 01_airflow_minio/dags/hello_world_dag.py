import pendulum
import logging
from airflow.sdk import DAG
from airflow.sdk import task
from airflow.providers.standard.operators.empty import EmptyOperator

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'retries': 0
}

dag = DAG(
    dag_id="branch_without_trigger",
    schedule="@once",
    start_date=pendulum.datetime(2019, 2, 28, tz="UTC"),
    catchup=False,
    tags=["debug"],
    render_template_as_native_obj=True,
    default_args=default_args
)

run_this_first = EmptyOperator(task_id="run_this_first", dag=dag)

@task.branch(task_id="branching")
def do_branching(**kwargs):
    logging.info("🔍 Exécution de la tâche 'branching'")
    logging.info("📦 kwargs reçus : %s", kwargs)
    selected_branch = "branch_a"
    logging.info(f"🔀 Branche sélectionnée : {selected_branch}")
    return selected_branch

branching = do_branching()

branch_a = EmptyOperator(task_id="branch_a", dag=dag)
follow_branch_a = EmptyOperator(task_id="follow_branch_a", dag=dag)

branch_false = EmptyOperator(task_id="branch_false", dag=dag)

join = EmptyOperator(task_id="join", dag=dag)
end = EmptyOperator(task_id="end", dag=dag)

run_this_first >> branching
branching >> branch_a >> follow_branch_a >> join
branching >> branch_false >> join
join >> end
