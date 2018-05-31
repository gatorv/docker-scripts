#!/bin/bash
# Script to create a MySQL image with a phpMyAdmin image

# Usage
function usage() {
    echo "Usage: $0 image_name mysql_password path_to_data host_mysql_port host_admin_port"
    exit 1
}

if [ $# -lt 5 ] ; then
    usage
    exit 1
fi

if [[ "$OSTYPE" == "darwin"* ]]; then
    command -v greadlink >/dev/null 2>&1 || { echo >&2 "Please install brew coreutils first. Aborting..."; exit 1; }
fi

# Variables
MYSQL_NAME="$1_mysql"
MYSQL_PASSWORD=$2
DB_PATH=$3
HOST_PORT=$4
PHPMYADMIN_PORT=$5
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    FULL_PATH=$(readlink -f $DB_PATH)
elif [[ "$OSTYPE" == "darwin"* ]]; then
    FULL_PATH=$(greadlink -f $DB_PATH)
fi
PHPMYADMIN_NAME="$1_admin"
NETWORK_NAME="$1_network"

# Create a network
docker network create ${NETWORK_NAME}
sleep 2

# Create a MySQL docker image
docker run \
    --detach \
    --name=${MYSQL_NAME} \
    --env MYSQL_ROOT_PASSWORD=${MYSQL_PASSWORD} \
    --publish ${HOST_PORT}:3306 \
    --net=${NETWORK_NAME} \
    --volume=${FULL_PATH}:/var/lib/mysql \
    mysql:5.7;

sleep 2
# Create a phpMyAdmin docker image
docker run \
    --detach \
    --name=${PHPMYADMIN_NAME} \
    --net=${NETWORK_NAME} \
    --publish ${PHPMYADMIN_PORT}:80 \
    --env PMA_HOST=${MYSQL_NAME} \
    phpmyadmin/phpmyadmin;

echo "Containers created use docker start/stop ${MYSQL_NAME} and/or docker start/stop ${PHPMYADMIN_NAME} to manipulate them"