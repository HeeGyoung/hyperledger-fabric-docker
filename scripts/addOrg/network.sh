#!/bin/bash

set -euo pipefail

. scripts/common/utils.sh

# Get docker sock path from environment variable
SOCK="${DOCKER_HOST:-/var/run/docker.sock}"
DOCKER_SOCK="${SOCK##unix://}"

NEW_ORG_NAME="userlog-org3.example.com"

function generateGryptogen() {
  if [ -d "organizations/peerOrganizations/${NEW_ORG_NAME}" ]; then
      rm -Rf organizations/peerOrganizations/${NEW_ORG_NAME}
  fi

  infoln "Generating cryptogen"
  ./bin/cryptogen generate --config=./organizations/cryptogen/crypto-config-org3.yaml --output="organizations"

  infoln "Generating CCP files for Org3"
  ./scripts/addOrg/ccp-generator.sh
}

function generateDefinition() {
  set -x
  ./bin/configtxgen -printOrg Org3MSP -configPath ${PWD}/addorg-configtx > organizations/peerOrganizations/${NEW_ORG_NAME}/org3.json
  res=$?
  { set +x; } 2>/dev/null
  if [ $res -ne 0 ]; then
    fatalln "Failed to generate Org3 organization definition..."
  fi
}

function newOrgUp() {
  DOCKER_SOCK=${DOCKER_SOCK} docker-compose -f fabric-network/docker-compose-addorg-couchdb.yaml -f fabric-network/docker-compose-local-org3.yaml up -d 2>&1
  if [ $? -ne 0 ]; then
    fatalln "ERROR !!!! Unable to start Org3 network"
  fi
}

generateGryptogen

infoln "Generate Definition"
generateDefinition

infoln "Bring up new org"
newOrgUp

infoln "Generating and submitting config tx to add Org3"
CHANNEL_NAME="userlog-channel"
docker exec cli scripts/addOrg/update-channel-config.sh $CHANNEL_NAME 3 10 false
if [ $? -ne 0 ]; then
  fatalln "ERROR !!!! Unable to create config tx"
fi
