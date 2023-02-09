#! /usr/bin/env bash
CONTAINER_NAME=$1
TARBALL_NAME=$2
DATABASE_NAME=$3
USER_NAME=$4
PASSWORD=$5

BACKUP_FOLDER=/data/databases/backups
array=(${TARBALL_NAME//./ })
ORIGINAL_DB_NAME=${array[1]}

if [ -z $CONTAINER_NAME ]
then
  echo "Usage: $0 [container name] [backup file(tar.gz) name] [database name]"
  exit 1
fi

if [ -z $DATABASE_NAME ]
then
  echo "Usage: $0 [container name] [backup file(tar.gz) name] [database name]"
  exit 1
fi

if [ -z $TARBALL_NAME ]
then
  echo "Usage: $0 [container name] [backup file(tar.gz) name] [database name]"
  exit 1
fi

if [ -z $USER_NAME ]
then
  USER_NAME=neo4j
fi

if [ -z $PASSWORD ]
then
  PASSWORD=password
fi


# Set bash to exit if any further command fails
set -e
set -o pipefail

docker cp ./$TARBALL_NAME $CONTAINER_NAME:$BACKUP_FOLDER
docker exec -it "$CONTAINER_NAME" /bin/sh -c "mkdir -p $BACKUP_FOLDER/$DATABASE_NAME;rm -rf $BACKUP_FOLDER/$DATABASE_NAME/*;tar xf $BACKUP_FOLDER/$TARBALL_NAME --directory $BACKUP_FOLDER/$DATABASE_NAME;mv $BACKUP_FOLDER/$DATABASE_NAME/$ORIGINAL_DB_NAME/* $BACKUP_FOLDER/$DATABASE_NAME"

echo ""
echo "Restoring database '$DATABASE_NAME' in the container '$CONTAINER_NAME'..."

eval=`docker exec -it $CONTAINER_NAME cypher-shell -u $USER_NAME -p $PASSWORD -d system "SHOW DATABASE $DATABASE_NAME YIELD name"`
echo "$eval"
echo "The target db name is $DATABASE_NAME"

if [[ $eval == *"$DATABASE_NAME"* ]] || [ "$DATABASE_NAME" == "$ORIGINAL_DB_NAME" ]; then
    echo "Restore to the existing database and is stopping the DB"
    docker exec -it $CONTAINER_NAME cypher-shell -u $USER_NAME -p $PASSWORD -d system "STOP DATABASE $DATABASE_NAME"
fi

docker exec -it $CONTAINER_NAME  bin/neo4j-admin restore --from=$BACKUP_FOLDER/$DATABASE_NAME --database=$DATABASE_NAME --force

if [[ $eval == *"$DATABASE_NAME"* ]] || [ "$DATABASE_NAME" == "$ORIGINAL_DB_NAME" ]; then
    echo "Start up the DB $DATABASE_NAME"
    docker exec -it $CONTAINER_NAME cypher-shell -u $USER_NAME -p $PASSWORD -d system "START DATABASE $DATABASE_NAME"
  else
   docker exec -it "$CONTAINER_NAME" bin/cypher-shell -u $USER_NAME -p $PASSWORD -d system "CREATE DATABASE $DATABASE_NAME"
fi
echo "Done!"
