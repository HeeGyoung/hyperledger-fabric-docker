#!/bin/bash

# Get docker sock path from environment variable
SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
DOCKER_SOCK="${SOCK##unix://}"

. scripts/common/utils.sh
. scripts/common/env_var.sh

if [ -d "organizations/peerOrganizations/userlog-org2.${SWITCHWON_DOMAIN}/peers/peer1.userlog-org2.${SWITCHWON_DOMAIN}" ]; then
    rm -Rf organizations/peerOrganizations/userlog-org2.${SWITCHWON_DOMAIN}/peers/peer1.userlog-org2.${SWITCHWON_DOMAIN}
fi

set -x
./bin/cryptogen extend --config=./organizations/cryptogen/crypto-config-org2.yaml --input="organizations"

DOCKER_SOCK="${DOCKER_SOCK}" docker-compose -f fabric-network/docker-compose-addpeer-couchdb.yaml \
-f fabric-network/docker-compose-addpeer-org2.yaml up -d 2>&1

{ set +x; } 2>/dev/null
docker ps -a
