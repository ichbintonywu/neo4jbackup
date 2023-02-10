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

mkdir -p "./backups"
docker exec -it "$CONTAINER_NAME"  mkdir -p $BACKUP_PATH
echo "Backing up database '$DATABASE_NAME' from container '$CONTAINER_NAME'..."

ALL_DB="all"
# Copy the created file out of the container to the host filesystem
if [ "$DATABASE_NAME" == "$ALL_DB" ]; then
  echo "Back up all databases"
  docker exec -it "$CONTAINER_NAME"  bin/neo4j-admin database backup --to-path=$BACKUP_PATH \*
  docker exec -it "$CONTAINER_NAME"  /bin/sh -c "mkdir -p /extract;rm -rf /extract/*; cp -f $BACKUP_PATH/*.backup /extract"
  docker cp $CONTAINER_NAME:/extract/.  ./backups
  docker exec -it "$CONTAINER_NAME" /bin/sh -c "cd $BACKUP_PATH;rm *"

else
  echo "Back up database - $DATABASE_NAME"
  docker exec -it "$CONTAINER_NAME"  bin/neo4j-admin database backup --to-path=$BACKUP_PATH $DATABASE_NAME
  docker exec -ti "$CONTAINER_NAME"  bin/neo4j-admin database aggregate-backup --from-path=$BACKUP_PATH $DATABASE_NAME
  docker exec -it "$CONTAINER_NAME"  /bin/sh -c "mkdir -p /extract;rm -rf /extract/*; cp -f $BACKUP_PATH/*.backup /extract"
  docker cp $CONTAINER_NAME:/extract/.  ./backups
  docker exec -it "$CONTAINER_NAME" /bin/sh -c "cd $BACKUP_PATH;rm *"

fi

echo "Backed up database '$DATABASE_NAME' to ./backups"
echo "Done!"
