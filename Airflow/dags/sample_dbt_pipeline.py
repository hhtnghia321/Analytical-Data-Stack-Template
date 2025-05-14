from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    "start_date": datetime(2023, 1, 1),
    "retries": 1,
    "retry_delay": timedelta(minutes=5),
}

with DAG("dbt_run_in_project", schedule_interval=None, default_args=default_args, catchup=False) as dag:

    dbt_run = BashOperator(
        task_id="run_dbt",
        bash_command="""
        cd /opt/airflow/OCB_Pipeline && \
        dbt-ol run --models query2 --debug
        """,
        execution_timeout=timedelta(minutes=60),
    )
