#!/bin/bash

if [ -d "./backup" ]; then
    rm -Rf ./backup
fi

mkdir ./backup
cp -r ./organizations/ ./backup/organizations
cp -r ./channel-artifacts ./backup/channel-artifacts

docker container cp peer0.userlog-org1.example.com:/var/hyperledger/production ./backup/peer0.userlog-org1
docker container cp peer1.userlog-org1.example.com:/var/hyperledger/production ./backup/peer1.userlog-org1
docker container cp peer0.userlog-org2.example.com:/var/hyperledger/production ./backup/peer0.userlog-org2
docker container cp orderer-userlog.example.com:/var/hyperledger/production/orderer ./backup/orderer-userlog