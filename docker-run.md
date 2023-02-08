
#create folder for volume mapping
mkdir -p neo4j/logs neo4j/data neo4j/plugins neo4j/import

#pull and run docker
docker run --name neo4j \
    -p7474:7474 -p7687:7687 \
    -d \
    -v ~/data:/data \
    -v ~/logs:/logs \
    -v ~/import:/import \
    -v ~/plugins:/plugins \
    --env NEO4J_AUTH=neo4j/password \
    --env NEO4J_ACCEPT_LICENSE_AGREEMENT=yes \
    neo4j:4.4.7-enterprise


#backup commandline
./neo4j_backup.4.x.sh neo4j neo4j
