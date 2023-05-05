#!/bin/bash

DELAY="3"
MAX_RETRY="5"
VERBOSE="false"
TIMEOUT="10"

SWITCHWON_DOMAIN="example.com"
ORDERER="orderer-userlog"
PEER_ORG1="userlog-org1"
PEER_ORG2="userlog-org2"
PEER_ORG3="userlog-org3"
CHANNEL_NAME="userlog-channel"
BLOCKFILE="./channel-artifacts/${CHANNEL_NAME}.block"
CHAINCODE_NAME="mychaincode"

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/${SWITCHWON_DOMAIN}/tlsca/tlsca.${SWITCHWON_DOMAIN}-cert.pem
export PEER0_ORG1_CA=${PWD}/organizations/peerOrganizations/${PEER_ORG1}.${SWITCHWON_DOMAIN}/tlsca/tlsca.${PEER_ORG1}.${SWITCHWON_DOMAIN}-cert.pem
export PEER0_ORG2_CA=${PWD}/organizations/peerOrganizations/${PEER_ORG2}.${SWITCHWON_DOMAIN}/tlsca/tlsca.${PEER_ORG2}.${SWITCHWON_DOMAIN}-cert.pem
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/${PEER_ORG3}.${SWITCHWON_DOMAIN}/tlsca/tlsca.${PEER_ORG3}.${SWITCHWON_DOMAIN}-cert.pem
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/${SWITCHWON_DOMAIN}/orderers/${ORDERER}.${SWITCHWON_DOMAIN}/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/${SWITCHWON_DOMAIN}/orderers/${ORDERER}.${SWITCHWON_DOMAIN}/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_ORG=$1
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="Org1MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG1_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${PEER_ORG1}.${SWITCHWON_DOMAIN}/users/Admin@${PEER_ORG1}.${SWITCHWON_DOMAIN}/msp
    export CORE_PEER_ADDRESS=localhost:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="Org2MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG2_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${PEER_ORG2}.${SWITCHWON_DOMAIN}/users/Admin@${PEER_ORG2}.${SWITCHWON_DOMAIN}/msp
    export CORE_PEER_ADDRESS=localhost:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/${PEER_ORG3}.${SWITCHWON_DOMAIN}/users/Admin@${PEER_ORG3}.${SWITCHWON_DOMAIN}/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi
}

# Set environment variables for use in the CLI container
setGlobalsCLI() {
  local USING_ORG=$1

  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.${PEER_ORG1}.${SWITCHWON_DOMAIN}:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.${PEER_ORG2}.${SWITCHWON_DOMAIN}:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.${PEER_ORG3}.${SWITCHWON_DOMAIN}:11051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.userlog-org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	    PEERS="$PEER"
    else
	    PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}
