from airflow import DAG
from airflow.operators.bash import BashOperator
from datetime import datetime

default_args = {"start_date": datetime(2023, 1, 1)}

with DAG("dbt_via_exec", schedule_interval=None, default_args=default_args, catchup=False) as dag:

    dbt_run = BashOperator(
        task_id="run_dbt_in_container",
        bash_command="docker exec dbt_container_name dbt run --project-dir /usr/app/dbt/raffle_shop --profiles-dir /usr/app/dbt/raffle_shop",
    )
