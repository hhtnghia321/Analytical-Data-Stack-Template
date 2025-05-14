FROM apache/airflow:2.8.4-python3.11

USER root  

RUN apt-get update && apt-get install -y \
    bash \
    python3 \
    python3-pip \
    python3-dev \
    python3.11-venv \
    curl \
    vim \
    ssh \
    nano \
    git \
    # ping\
    && rm -rf /var/lib/apt/lists/*

USER airflow

RUN pip install --upgrade pip setuptools wheel

RUN pip install --no-cache-dir \
    numpy \
    pandas \
    flask \
    dbt-core \
    dbt-trino \
    openlineage-dbt \
    psycopg2-binary

RUN mkdir -p /opt/airflow/DBT/dbt_profiles

RUN dbt init OCB_Pipeline --skip-profile-setup

EXPOSE 5000
