#!/bin/bash

. scripts/common/utils.sh
. scripts/common/env_var.sh
. scripts/common/chaincode-utils.sh

#export FABRIC_CFG_PATH=$PWD/../config/
export FABRIC_CFG_PATH=$PWD/fabric-network/docker/peercfg/

PACKAGE_ID=$(./bin/peer lifecycle chaincode calculatepackageid ${CHAINCODE_NAME}.tar.gz)
export CC_PACKAGE_ID=${PACKAGE_ID}

warnBoldln "Now can query data from chaincode"
chaincodeQuery 1 '{"Args":["GetAllAssets"]}' localhost:7051
chaincodeQuery 1 '{"Args":["GetAllAssets"]}' localhost:7054
chaincodeQuery 2 '{"Args":["GetAllAssets"]}' localhost:9051
