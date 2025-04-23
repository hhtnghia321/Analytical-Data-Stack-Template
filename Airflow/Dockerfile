FROM apache/airflow:2.1.1

USER root

RUN apt-get update && apt-get install -y docker.io

RUN groupadd -g 999 docker && \
    usermod -aG docker default

USER airflow
