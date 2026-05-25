#!/bin/bash

#---------- SECTION TO EDIT --------------

#Change this to the source file of your install to get the good IDs, must have the db root password.
source /Users/Shared/Beaupeyrat/Db-SIO/.env
#MYSQL_ROOT_PASSWORD= #Uncomment and fill this line if you don't use .env file

# Is the database in a container ?
DOCKERIZED=1
DOCKER_CONTAINER_NAME="DB-SIO-mariadb"

# which host 
MYSQL_HOST=127.0.0.1

# Shouldn't need change but in case...
BACKUP_DIR="/backup" #base directory for backups
HOLD_DAYS=7 #days kept on the server
TIMESTAMP=$(date +"%F") #backup date folder format

#---------- END SECTION TO EDIT ----------

MYSQL_CMD=mariadb
MYSQL_DMP=mariadb-dump
MYSQL_CHECK=mariadb-check
MYSQL_USR=root #Do not use MYSQL_USER, defined in .env
MYSQL_PORT=3307
MYSQL_BACKUP_DIR="$BACKUP_DIR/mariadb"
MYSQL_BACKUP_NAME=mariadb

REPAIR_CMD="$MYSQL_CHECK -h $MYSQL_HOST  -u $MYSQL_USR --password=$MYSQL_ROOT_PASSWORD --auto-repair --all-databases --skip_ssl"
CREATE_BACKUP_DIR_CMD="mkdir -p "$BACKUP_DIR/$TIMESTAMP""
DUMP_CMD="$MYSQL_DMP --user=$MYSQL_USR --password=$MYSQL_ROOT_PASSWORD --lock-tables --all-databases > "dbs_alldatabases.sql" | gzip > "$MYSQL_BACKUP_NAME.gz" && rm dbs_alldatabases.sql"
CLEAN_CMD="find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d -mtime +$HOLD_DAYS -exec rm -rf {} \;"

if [[ $DOCKERIZED -eq 1 ]]; then
    echo "Starting backup for a container named $DOCKER_CONTAINER_NAME"
else
    echo "Starting backup for the host $MYSQL_HOST"
fi

# Check and auto-repair all databases first
echo
echo "Repairing all databases - this can take a while ..."
if [[ $DOCKERIZED -eq 1 ]]; then
    docker exec -d $DOCKER_CONTAINER_NAME bash -c "$REPAIR_CMD"
else
    $REPAIR_CMD
fi

# Create backup dir
echo
echo "Creating backup dir ..."
if [[ $DOCKERIZED -eq 1 ]]; then
    docker exec -d $DOCKER_CONTAINER_NAME bash -c "$CREATE_BACKUP_DIR_CMD"
else
    $CREATE_BACKUP_DIR_CMD
fi

#Dump all databases and gzip
echo
echo "Dumping all databases and gzipping"
if [[ $DOCKERIZED -eq 1 ]]; then
    docker exec -d -w "$BACKUP_DIR/$TIMESTAMP" $DOCKER_CONTAINER_NAME bash -c "$DUMP_CMD"
else
    $DUMP_CMD
fi

echo
echo "Cleaning up ..."
if [[ $DOCKERIZED -eq 1 ]]; then
    docker exec -d -w "$BACKUP_DIR/$TIMESTAMP" $DOCKER_CONTAINER_NAME bash -c "$CLEAN_CMD"
else
    $CLEAN_CMD
fi
echo "-- DONE!"