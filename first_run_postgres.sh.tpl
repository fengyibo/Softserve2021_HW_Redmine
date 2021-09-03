#!/bin/bash

#Updating system packages
sudo apt update && sudo apt upgrade -y

#Installing Docker engine
sudo apt install docker.io

#Running postresql instance with predefined environment
docker run -d --name postgres -p 5432:5432 \
	-v /home/ubuntu/postgres/db:/var/lib/postgresql \
	-v /home/ubuntu/postgres/data:/var/lib/postgresql/data \
	-e POSTGRES_USER=${DB_USER} \
	-e POSTGRES_PASSWORD=${DB_PASSWORD} \
	-e POSTGRES_DB=${DB_NAME} \
	postgres:9.6
