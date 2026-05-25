#!/bin/bash
#Change this to the source file of your install to get the good IDs
source /Users/Shared/Beaupeyrat/Db-SIO/.env

#Section to edit
DOCKERIZED=1
DATABASES_HOST=127.0.0.1
BACKUP_DIR="/backup"

#Change if needed
HOLD_DAYS=7 
TIMESTAMP=$(date +"%F")

### mariadb
MYSQL_CMD=mariadb
MYSQL_DMP=mariadb-dump
MYSQL_CHECK=mariadb-check
MYSQL_USR=root #Do not use MYSQL_USER, defined in .env
MYSQL_PORT=3307
MYSQL_BACKUP_DIR="$BACKUP_DIR/mariadb"
MYSQL_BACKUP_NAME=mariadb

docker ps 

# Check and auto-repair all databases first
echo
echo "Repairing all databases - this can take a while ..."
docker exec -d DB-SIO-mariadb bash -c "$MYSQL_CHECK -h $MYSQL_HOST  -u $MYSQL_USR --password=$MYSQL_PWD --auto-repair --all-databases --skip_ssl"

# Backup
echo
echo "Starting backup ..."
docker exec -d DB-SIO-mariadb bash -c "mkdir -p "$BACKUP_DIR/$TIMESTAMP""
#echo "$MYSQL_DMP --user=$MYSQL_USR --password=$MYSQL_ROOT_PASSWORD --lock-tables --all-databases > "$BACKUP_DIR/$TIMESTAMP/dbs_alldatabases.sql" | gzip > "$BACKUP_DIR/$TIMESTAMP/$MYSQL_BACKUP_NAME.gz""
docker exec -d -w "$BACKUP_DIR/$TIMESTAMP" DB-SIO-mariadb bash -c "$MYSQL_DMP --user=$MYSQL_USR --password=$MYSQL_ROOT_PASSWORD --lock-tables --all-databases > "dbs_alldatabases.sql" | gzip > "$MYSQL_BACKUP_NAME.gz""

echo
echo "Cleaning up ..."
#find $BACKUP_DIR -maxdepth 1 -mindepth 1 -type d -mtime +$HOLD_DAYS -exec rm -rf {} \;
echo "-- DONE!"