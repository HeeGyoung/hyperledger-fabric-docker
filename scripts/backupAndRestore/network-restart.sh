#!/bin/bash

docker stop cli \
peer0.userlog-org1.example.com \
peer1.userlog-org1.example.com \
peer0.userlog-org2.example.com \
orderer-userlog.example.com \
couchdb-peer0-org1 \
couchdb-peer1-org1 \
couchdb-peer0-org2 \
couchdb-peer1-org2

docker rm cli \
peer0.userlog-org1.example.com \
peer1.userlog-org1.example.com \
peer0.userlog-org2.example.com \
orderer-userlog.example.com \
couchdb-peer0-org1 \
couchdb-peer1-org1 \
couchdb-peer0-org2 \
couchdb-peer1-org2

docker volume prune

SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
DOCKER_SOCK="${SOCK##unix://}"

DOCKER_SOCK="${DOCKER_SOCK}" docker-compose -f fabric-network/docker-compose-local-couchdb.yaml \
-f fabric-network/docker-compose-local-org1.yaml \
-f fabric-network/docker-compose-local-org2.yaml \
-f fabric-network/docker-compose-local-orderer.yaml \
-f fabric-network/docker-compose-local-cli.yaml up -d 2>&1

docker ps -a