#!/bin/bash
cd `dirname $0`
cd ../

export WORKSPACE=`pwd`

if [ ! -n "$1" ];
then
	echo "Usage:"
	echo "	run.sh <structure>"
	echo "	Please indicate the structure you wanna to setup, eg. ./run.sh webapp"
	exit 1;
fi

if [ "$1" = "webapp" ];
then
	source ${WORKSPACE}/webapp/config/setenv.sh

	docker-compose -f ${WORKSPACE}/webapp/compose/docker-compose.yaml up -d

	# To make sure postgres container service has been ready to be inserted data, sleep 20s
	sleep 20
	
	docker run \
	--rm \
	--net bridge \
	-e PGPASSWORD=${PG_PASSWORD} \
	-v ${WORKSPACE}/webapp/data:/tmp/data \
	--link mypostgres:postgres postgres psql \
	-h postgres \
	-U postgres \
	-f /tmp/data/pgdata.sql

elif [ "$1" = "xxx" ];
then
	echo "I am xxx"
else
	echo "the structure name you providing is invalid."
fi

