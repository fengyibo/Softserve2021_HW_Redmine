#!/bin/bash

#Updating system packages
sudo apt update && sudo apt upgrade -y

#Installing Docker engine
sudo apt install docker.io -y

#Running redmine instance with predefined environment
docker run -d --name redmine -p 3000:3000 \
	-e REDMINE_DB_POSTGRES=${POSTGRES_IP} \
	-e REDMINE_DB_PASSWORD=${DB_PASSWORD} \
	-e REDMINE_DB_DATABASE=${DB_NAME} \
	-e REDMINE_DB_USERNAME=${DB_USER} \
	-e REDMINE_SECRET_KEY_BASE=${REDMINE_KEY} \
	-e REDMINE_NO_DB_MIGRATE=1 \
	redmine:4.2
