#!/bin/bash

. scripts/common/env_var.sh
. scripts/common/utils.sh
. scripts/common/update-config.sh

NEW_ORG_NAME="userlog-org3.example.com"

infoln "Creating config transaction to add new org to network"

# Fetch the config for the channel, writing it to config.json
fetchChannelConfig 1 ${CHANNEL_NAME} config.json

# Modify the configuration to append the new org
set -x
jq -s '.[0] * {"channel_group":{"groups":{"Application":{"groups": {"Org3MSP":.[1]}}}}}' config.json ${PWD}/organizations/peerOrganizations/${NEW_ORG_NAME}/org3.json > modified_config.json
{ set +x; } 2>/dev/null

# Compute a config update, based on the differences between config.json and modified_config.json, write it as a transaction to org3_update_in_envelope.pb
createConfigUpdate ${CHANNEL_NAME} config.json modified_config.json org3_update_in_envelope.pb

infoln "Signing config transaction"
signConfigtxAsPeerOrg 1 org3_update_in_envelope.pb

infoln "Submitting transaction from a different peer (peer0.org2) which also signs it"
setGlobals 2
set -x
peer channel update -f org3_update_in_envelope.pb -c ${CHANNEL_NAME} -o ${ORDERER}.${SWITCHWON_DOMAIN}:7050 --ordererTLSHostnameOverride ${ORDERER}.${SWITCHWON_DOMAIN} --tls --cafile "$ORDERER_CA"
{ set +x; } 2>/dev/null

successln "Config transaction to add org3 to network submitted"