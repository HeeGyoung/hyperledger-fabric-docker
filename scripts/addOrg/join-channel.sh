#!/bin/bash

. scripts/common/utils.sh
. scripts/common/env_var.sh
. scripts/common/channel-utils.sh

ORG=3
setGlobals ${ORG}
setGlobalsCLI ${ORG}
BLOCKFILE="channel-artifacts/addorg-config.block"

#export FABRIC_CFG_PATH=$PWD/../config/
export FABRIC_CFG_PATH=$PWD/fabric-network/docker/peercfg/

echo "Fetching channel config block from orderer..."
set -x
./bin/peer channel fetch 0 ${BLOCKFILE} -o localhost:7050 --ordererTLSHostnameOverride ${ORDERER}.${SWITCHWON_DOMAIN} -c $CHANNEL_NAME --tls --cafile "$ORDERER_CA" >&log.txt
res=$?
{ set +x; } 2>/dev/null
cat log.txt
verifyResult $res "Fetching config block from orderer has failed"

infoln "Joining org3 peer to the channel..."
joinChannel ${ORG} localhost:11051
joinChannel ${ORG} localhost:11054

infoln "Setting anchor peer for org3..."
setAnchorPeer ${ORG}

successln "Channel '$CHANNEL_NAME' joined"
successln "Org3 peer successfully added to network"