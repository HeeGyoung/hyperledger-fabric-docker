#!/bin/bash

. scripts/common/utils.sh
. scripts/common/env_var.sh
. scripts/common/chaincode-utils.sh

#export FABRIC_CFG_PATH=$PWD/../config/
export FABRIC_CFG_PATH=$PWD/fabric-network/docker/peercfg/

warnBoldln "Install chaincode into new peer"
installChaincode 2 localhost:9054

PACKAGE_ID=$(./bin/peer lifecycle chaincode calculatepackageid ${CHAINCODE_NAME}.tar.gz)
export CC_PACKAGE_ID=${PACKAGE_ID}

warnBoldln "Now can query data from chaincode"
chaincodeQuery 2 '{"Args":["GetAllAssets"]}' localhost:9054

warnBoldln "Create new asset"
CHAINCODE_CRATE_ASSET_FUNCTION="CreatAsset"
CHAINCODE_ASSET='"{\"ID\":\"asset8\",\"Color\":\"Purple\",\"Size\":10,\"Owner\":\"Peer2Org2\",\"AppraisedValue\":500}"'
FCN_CALL='{"Args":["'${CHAINCODE_CRATE_ASSET_FUNCTION}'",'${CHAINCODE_ASSET}']}'
chaincodeInvoke 1 2 false

warnBoldln "Query created asset from new peer"
chaincodeQuery 2 '{"function":"ReadAsset","Args":["asset8"]}' localhost:9054

warnBoldln "Update new asset"
CHAINCODE_CRATE_ASSET_FUNCTION="UpdateAsset"
CHAINCODE_ASSET='"{\"ID\":\"asset8\",\"Color\":\"Purple\",\"Size\":10,\"Owner\":\"UPDATED!!!\",\"AppraisedValue\":500}"'
FCN_CALL='{"Args":["'${CHAINCODE_CRATE_ASSET_FUNCTION}'",'${CHAINCODE_ASSET}']}'
chaincodeInvoke 1 2 false

warnBoldln "Query updated asset from new peer"
chaincodeQuery 2 '{"function":"ReadAsset","Args":["asset8"]}' localhost:9054

warnBoldln "Now can query data from chaincode"
chaincodeQuery 2 '{"Args":["GetAllAssets"]}' localhost:9054