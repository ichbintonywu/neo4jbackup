# Backup Scripts for a Containerized Neo4j

## Backup script for running Neo4j


Sample script to jump into docker to run online backup and pull back to local directory ./backup, and restore a database from the backup tar file. 

Samples to run the scripts. They are tested on Neo4j v4.4.7 and v5.4.0 docker image.

### to backup database testdb in the container neo4j
./neo4j_backup.4.x.sh neo4j testdb 

### to backup all databases in the container neo4j
./neo4j_backup.4.x.sh neo4j all

### to restore a db from  a tar file which is the backup of db - testdb to the new database testdb2 in the container neo4j
./neo4j_restore.4.x.sh neo4j 2023-02-08T12-56-10.testdb.tar.gz testdb2


### to restore a db from a tar file which is the backup of db - testdb to override the existing database - testdb in the container neo4j
./neo4j_restore.4.x.sh neo4j 2023-02-08T12-56-10.testdb.tar.gz testdb
