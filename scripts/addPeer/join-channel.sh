#!/bin/bash

. scripts/common/utils.sh
. scripts/common/env_var.sh
. scripts/common/channel-utils.sh

ORG=2
setGlobals ${ORG}
setGlobalsCLI ${ORG}

#export FABRIC_CFG_PATH=$PWD/../config/
export FABRIC_CFG_PATH=$PWD/fabric-network/docker/peercfg/

infoln "Fetching channel config block from orderer..."
BLOCKFILE="channel-artifacts/peerjoin-cofig.block"
set -x
./bin/peer channel fetch 0 ${BLOCKFILE} -o localhost:7050 --ordererTLSHostnameOverride ${ORDERER}.${SWITCHWON_DOMAIN} -c ${CHANNEL_NAME} --tls --cafile "$ORDERER_CA"
res=$?
{ set +x; } 2>/dev/null
cat log.txt
verifyResult $res "Fetching config block from orderer has failed"

infoln "Joining org${ORG} peer1 to the channel..."
joinChannel 2 localhost:9054

