#!/bin/sh
SERVICE_NAME=dbcluster
docker network create myoverlay --driver overlay
docker service create -e DNS=tasks.$SERVICE_NAME -e MYSQL_ROOT_PASSWORD=12345678 --network=myoverlay --name abc $SERVICE_NAME
