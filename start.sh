#!/bin/sh
SERVICE_NAME=dbcluster
docker network create myoverlay --driver overlay
docker service create -e DNS=tasks.$SERVICE_NAME -e MYSQL_ROOT_PASSWORD=12345678 -e MYSQL_DATABASE=database_production -e MYSQL_USER=dbuser -e MYSQL_PASSWORD=12345678 --network=myoverlay --name $SERVICE_NAME dbserver
