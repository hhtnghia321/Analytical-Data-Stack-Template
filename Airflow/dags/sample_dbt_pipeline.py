from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {
    "start_date": datetime(2023, 1, 1),
}

with DAG("dbt_run_in_project", schedule_interval=None, default_args=default_args, catchup=False) as dag:

    dbt_run = BashOperator(
        task_id="run_dbt",
        bash_command="""
        docker exec dbt_trino bash -c "cd /usr/app/dbt/raffle_shop && dbt-ol run --select query --target postgres2"
        """,
    )
