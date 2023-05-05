### Required installation.
1. curl -sSLO https://raw.githubusercontent.com/hyperledger/fabric/main/scripts/install-fabric.sh && chmod +x install-fabric.sh\n
2. ./install-fabric.sh binary | ./install-fabric.sh --fabric-version 2.2.1 docker
3. brew install jq
4. docker pull hyperledger/fabric-nodeenv:amd64-2.4.2
5. docker tag 31959bcd1525 hyperledger/fabric-nodeenv:2.4 # (31959bcd1525 -> This is "hyperledger/fabric-nodeenv"'s imageID)
6. docker rmi hyperledger/fabric-nodeenv:amd64-2.4.2

### Up fabric network
7. ./scripts/network.sh
8. ./scripts/create-channel.sh
9. ./script/deploy-chaincode.sh


### Add new Peer in an organization - using peer2 under org2 as an example here.
1. Increase Template.Count from 1 to 2 in {projectFilePath}/organizations/cryptogen/crypto-config-org2.yaml file.
2. ./scripts/addPeer/network.sh
3. ./scripts/addPeer/join-channel.sh
4. ./scripts/addPeer/deploy-chaincode.sh

### Add new Organization - using Org3 as an example here.
1. create crypto-config for the new organization. (ex. organizations/cryptogen/crypto-config-org3.yaml)
2. create docker-compose file for the new organization. (ex. fabric-newtwork/docker-compose-local-org3.yaml)
3. ./scripts/addOrg/network.sh
4. ./scripts/addOrg/join-channel.sh
5. ./scripts/addOrg/deploy-chaincode.sh

### Access CouchDB GUI
GUI url: http://127.0.0.1:*984/_utils (check peer's port in docker compose file)

#### Backup and Restore
1. ./scripts/backupAndRestore/create-backup.sh
2. Uncomment in docker-compose-local-org1, docker-compose-local-org2, docker-compose-local-orderer yaml files like below
> #- peer0.userlog-org2.example.com:/var/hyperledger/production
      - ../backup/peer0.userlog-org2:/var/hyperledger/production
> #- peer1.userlog-org1.example.com:/var/hyperledger/production
      - ../backup/peer1.userlog-org1:/var/hyperledger/production
> #- peer0.userlog-org1.example.com:/var/hyperledger/production
      - ../backup/peer0.userlog-org1:/var/hyperledger/production
> #- orderer-userlog.example.com:/var/hyperledger/production/orderer 
      - ../backup/orderer-userlog:/var/hyperledger/production/orderer
3. ./scripts/backupAndRestore/network-restart.sh
4. Check chaincode script > ./scripts/backupAndRestore/check-chaincode.sh

### Update chaincode
1. Uncomment "UpdateChaincodeTest" function in /atcc/assetTransfer.ts
2. ./scripts/updateChainCode/update-chaincode.sh
> Update(re-deploy) is same with the first deploy process. 
> Only thing should do is increasing chaincode version and sequence number.
> There is no "Revert" concept in SmartContract. 

# Backend dApp
cd backend
npm install
npm run build
npm run dev
swagger: http://localhost:8000/api-docs
