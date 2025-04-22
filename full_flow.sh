#### Install dependencies ####
echo "------------- Updating system and installing dependencies..."
sudo apt-get update
sudo apt-get install -y ca-certificates curl gnupg git  # Ensure git is installed

# Install Docker and Docker Compose
echo "------------- Installing Docker and Docker Compose..."
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# # Create Docker group and allow running without sudo
# echo "------------- Adding user to docker group..."
# sudo usermod -aG docker $USER 
# newgrp docker

#### Create Docker network ####
echo "------------- Creating Docker network..."
# Check if network already exists
if ! sudo docker network inspect network_test > /dev/null 2>&1; then
    echo "Creating network_test..."
    sudo docker network create \
      --driver=bridge \
      --subnet=172.18.0.0/16 \
      --gateway=172.18.0.1 \
      network_test
else
    echo "------------- Network 'network_test' already exists."
fi

# Check the network list
echo "------------- Checking available Docker networks..."
sudo docker network ls

#### Clone Repositories ####
echo "------------- Cloning postgres-frame-docker repository..."
# cd ~/docker-projects || exit  # Make sure to exit if the directory doesn't exist
# Remove the existing directory if it exists
TARGET_DIR=~/postgres-frame-docker
if [ -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' exists. Removing it..."
    rm -rf "$TARGET_DIR"
fi

git clone https://github.com/hhtnghia321/postgres-frame-docker.git
if [ $? -ne 0 ]; then
    echo "Error cloning postgres-frame-docker repository!"
    exit 1  # Exit if the git clone fails
else
    echo "Successfully cloned postgres-frame-docker repository."
fi

#### Start Postgres container ####
echo "------------- Starting Postgres container..."
sudo docker compose -f ./postgres-frame-docker/docker-compose.yml up -d
if [ $? -ne 0 ]; then
    echo "Error starting Postgres container!"
    exit 1
else
    echo "Postgres container started successfully."
fi

#### Set up Postgres database ####
echo "------------- Creating database and schema in Postgres..."
until [ "$(sudo docker inspect -f '{{.State.Health.Status}}' postgres)" == "healthy" ]; do
  echo "Waiting for postgres to be healthy..."
  sleep 2
done
sudo docker exec -it postgres psql -U postgres -c "create database trino_test;"
sudo docker exec -it postgres psql -U postgres -d trino_test -c "create schema testing;"

#### Copy data files to Postgres container ####
echo "------------- Copying data files to Postgres container..."
sudo docker cp ./postgres-frame-docker/raw_payments.txt postgres:/raw_payments.sql
sudo docker cp ./postgres-frame-docker/raw_orders.txt postgres:/raw_orders.sql
sudo docker cp ./postgres-frame-docker/raw_customers.txt postgres:/raw_customers.sql

#### Run SQL files in Postgres ####
echo "------------- Running SQL files in Postgres..."
sudo docker exec -it postgres psql -U postgres -d trino_test -v schema_name=testing -f /raw_payments.sql
sudo docker exec -it postgres psql -U postgres -d trino_test -v schema_name=testing -f /raw_orders.sql
sudo docker exec -it postgres psql -U postgres -d trino_test -v schema_name=testing -f /raw_customers.sql

#### Clone second repository ####
echo "------------- Cloning postgres-destination-build repository..."
TARGET_DIR=~/postgres-destination-build
if [ -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' exists. Removing it..."
    rm -rf "$TARGET_DIR"
fi

git clone https://github.com/TriHa91/postgres-destination-build.git
if [ $? -ne 0 ]; then
    echo "Error cloning postgres-destination-build repository!"
    exit 1
else
    echo "Successfully cloned postgres-destination-build repository."
fi

#### Start second container ####
echo "------------- Starting postgres-destination-build container..."
sudo docker compose -f ./postgres-destination-build/docker-compose.yml up -d

#### Set up second database and schema ####
echo "------------- Creating second database and schema..."
until [ "$(sudo docker inspect -f '{{.State.Health.Status}}' postgres_2)" == "healthy" ]; do
  echo "Waiting for postgres to be healthy..."
  sleep 2
done
sudo docker exec -it postgres_2 psql -U postgres_2 -c "create database postgres2;"
sudo docker exec -it postgres_2 psql -U postgres_2 -d postgres2 -c "create schema testing_write;"

#### Clone trino-build repository ####
echo "------------- Cloning trino-build repository..."
TARGET_DIR=~/trino-build
if [ -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' exists. Removing it..."
    rm -rf "$TARGET_DIR"
fi

git clone https://github.com/hhtnghia321/trino-build.git
if [ $? -ne 0 ]; then
    echo "Error cloning trino-build repository!"
    exit 1
else
    echo "Successfully cloned trino-build repository."
fi

#### Start Trino container ####
echo "------------- Starting Trino container..."
sudo docker compose -f ./trino-build/docker-compose.yml up -d


#### Clone dbt-trino-build repository ####
echo "------------- Cloning dbt-trino-template repository..."
TARGET_DIR=~/dbt-trino-template
if [ -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' exists. Removing it..."
    rm -rf "$TARGET_DIR"
fi

git clone https://github.com/hhtnghia321/dbt-trino-template.git
if [ $? -ne 0 ]; then
    echo "Error cloning dbt-trino-template repository!"
    exit 1
else
    echo "Successfully cloned dbt-trino-template repository."
fi

#### Start DBT container ####
echo "------------- Starting DBT container..."
sudo docker compose -f ./dbt-trino-template/docker-compose.yml up -d


#### Start Airflow repository ####
AIRFLOW_DIR="Airflow"
# mkdir -p "$AIRFLOW_DIR"
# curl -Lf -o "$AIRFLOW_DIR/docker-compose.yml" 'https://airflow.apache.org/docs/apache-airflow/2.1.1/docker-compose.yaml'
sudo AIRFLOW_UID=$(id -u) AIRFLOW_GID=0 docker compose -f "./Airflow/docker-compose.yml" up -d


#### Clone Marquez repository ####
echo "------------- Cloning marquez repository..."
TARGET_DIR=~/marquez
if [ -d "$TARGET_DIR" ]; then
    echo "Directory '$TARGET_DIR' exists. Removing it..."
    rm -rf "$TARGET_DIR"
fi

git clone https://github.com/hhtnghia321/marquez.git
if [ $? -ne 0 ]; then
    echo "Error cloning marquez repository!"
    exit 1
else
    echo "Successfully cloned marquez repository."
fi

#### Start Marquez container ####
echo "------------- Starting marquez container..."
cd marquez
sudo bash -x ./docker/up.sh --build --detach
cd ..

sudo docker network inspect network_test
echo "All tasks completed successfully."
