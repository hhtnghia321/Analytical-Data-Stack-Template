FROM apache/airflow:2.8.4-python3.11

RUN pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    numpy \
    pandas \
    flask \
    dbt-core \
    dbt-trino \
    psycopg2-binary

# RUN mkdir -p /opt/airflow/DBT/dbt_profiles

# ENV DBT_PROFILES_DIR=/opt/airflow/DBT/dbt_profiles

# WORKDIR /opt/airflow/DBT

RUN dbt init OCB_Pipeline --skip-profile-setup --project-dir /opt/airflow/DBT

EXPOSE 5000
