#!/bin/bash

. scripts/common/utils.sh
. scripts/common/env_var.sh
. scripts/common/chaincode-utils.sh

CHAINCODE_VERSION="1.0"
CHAINCODE_SEQUENCE="1"
INIT_REQUIRED="--init-required"

#export FABRIC_CFG_PATH=$PWD/../config/
export FABRIC_CFG_PATH=$PWD/fabric-network/docker/peercfg/

setGlobals 3
PACKAGE_ID=$(./bin/peer lifecycle chaincode calculatepackageid ${CHAINCODE_NAME}.tar.gz)
export CC_PACKAGE_ID=${PACKAGE_ID}

warnBoldln "1. installChaincode 3"
installChaincode 3 localhost:11051
installChaincode 3 localhost:11054

warnBoldln "2. Query whether the chaincode is installed 3"
queryInstalled 3 localhost:11051
queryInstalled 3 localhost:11054

warnBoldln "3. approveForMyOrg 1"
approveForMyOrg 3

warnBoldln "4. queryCommitted 3"
queryCommitted 3

warnBoldln "5. Get all assets from new Org3"
chaincodeQuery 3 '{"Args":["GetAllAssets"]}' localhost:11051
chaincodeQuery 3 '{"Args":["GetAllAssets"]}' localhost:11054

warnBoldln "6.(Create asset) chaincodeInvoke 1"
CHAINCODE_CRATE_ASSET_FUNCTION="CreatAsset"
CHAINCODE_ASSET='"{\"ID\":\"asset9\",\"Color\":\"DarkBlue\",\"Size\":10,\"Owner\":\"NewOrg3\",\"AppraisedValue\":500}"'
FCN_CALL='{"Args":["'${CHAINCODE_CRATE_ASSET_FUNCTION}'",'${CHAINCODE_ASSET}']}'
chaincodeInvoke 1 2 3 false

warnBoldln "7.(Get created asset using ID -) chaincodeQuery 3"
chaincodeQuery 3 '{"function":"ReadAsset","Args":["asset9"]}' localhost:11051
chaincodeQuery 3 '{"function":"ReadAsset","Args":["asset9"]}' localhost:11054

warnBoldln "8.(Update asset) chaincodeInvoke 1 2 3"
CHAINCODE_CRATE_ASSET_FUNCTION="UpdateAsset"
CHAINCODE_ASSET='"{\"ID\":\"asset9\",\"Color\":\"DarkBlue\",\"Size\":10,\"Owner\":\"UPDATED(NewOrg3)\",\"AppraisedValue\":500}"'
FCN_CALL='{"Args":["'${CHAINCODE_CRATE_ASSET_FUNCTION}'",'${CHAINCODE_ASSET}']}'
chaincodeInvoke 1 2 3 false

warnBoldln "8.(Get updated asset using ID -) chaincodeQuery 3"
chaincodeQuery 3 '{"function":"ReadAsset","Args":["asset9"]}' localhost:11051
chaincodeQuery 3 '{"function":"ReadAsset","Args":["asset9"]}' localhost:11054

warnBoldln "9. Get all assets from new Org3"
chaincodeQuery 3 '{"Args":["GetAllAssets"]}' localhost:11051
chaincodeQuery 3 '{"Args":["GetAllAssets"]}' localhost:11054