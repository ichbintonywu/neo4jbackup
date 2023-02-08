#! /usr/bin/env bash
CONTAINER_NAME=$1
DATABASE_NAME=$2

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

FILE_NAME=$(date +%Y-%m-%d_%H:%M:%S.$DATABASE_NAME)

mkdir -p "./backups"

echo "Backing up database '$DATABASE_NAME' from container '$CONTAINER_NAME'..."

docker exec -it "$CONTAINER_NAME"  bin/neo4j-admin backup --backup-dir=data/dumps/ --database=$DATABASE_NAME
docker exec -it "$CONTAINER_NAME"  tar czf data/dumps/$FILE_NAME.tar.gz data/dumps/$DATABASE_NAME

echo ""
echo "Exporting file from container..."

# Copy the created file out of the container to the host filesystem
docker cp $CONTAINER_NAME:data/dumps/$FILE_NAME.tar.gz ./backups/$FILE_NAME.tar.gz

echo "Backed up database '$DATABASE_NAME' to ./backups/$FILE_NAME"
echo "Done!"
