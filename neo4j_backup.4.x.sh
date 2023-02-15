#! /usr/bin/env bash
CONTAINER_NAME=$1
DATABASE_NAME=$2
BACKUP_PATH=/data/databases/backups
ALL_BACKUP_PATH=/data/databases

if [ -z $CONTAINER_NAME ]
then
  echo "Usage: $0 [container name] [database name]"
  exit 1
fi

if [ -z $DATABASE_NAME ]
then
  echo "Usage: $0 [container name] [database name]"
  exit 1
fi

# Set bash to exit if any further command fails
set -e
set -o pipefail
#generate a time stamp for file name
FILE_NAME=$(date +%Y-%m-%dT%H-%M-%S.$DATABASE_NAME)
ALL_BACKUPNAME=$(date +%Y-%m-%dT%H-%M-%S.allDBs)
#create a folder for backup
mkdir -p "./backups"
docker exec -it "$CONTAINER_NAME"  mkdir -p $BACKUP_PATH

echo "Backing up database '$DATABASE_NAME' from container '$CONTAINER_NAME'..."

#echo ""
#echo "Exporting file from container..."
ALL_DB="all"
# Copy the created file out of the container to the host filesystem
if [ "$DATABASE_NAME" == "$ALL_DB" ]; then
  echo "Back up all databases"
  docker exec -it "$CONTAINER_NAME"  bin/neo4j-admin backup --backup-dir=$BACKUP_PATH --database=*
  docker exec -it "$CONTAINER_NAME" tar czf $ALL_BACKUP_PATH/$ALL_BACKUPNAME.tar.gz --absolute-names $BACKUP_PATH
  docker cp $CONTAINER_NAME:$ALL_BACKUP_PATH/$ALL_BACKUPNAME.tar.gz ./backups/$ALL_BACKUPNAME.tar.gz
else
  echo "Back up database - $DATABASE_NAME"
  docker exec -it "$CONTAINER_NAME"  bin/neo4j-admin backup --backup-dir=$BACKUP_PATH --database=$DATABASE_NAME
  docker exec -it "$CONTAINER_NAME"  tar czf $BACKUP_PATH/$FILE_NAME.tar.gz --absolute-names $BACKUP_PATH/$DATABASE_NAME
  docker cp $CONTAINER_NAME:$BACKUP_PATH/$FILE_NAME.tar.gz ./backups/$FILE_NAME.tar.gz
fi

echo "Backed up database '$DATABASE_NAME' to ./backups/$FILE_NAME"
echo "Done!"
