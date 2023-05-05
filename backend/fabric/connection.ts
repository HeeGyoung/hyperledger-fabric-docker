import * as grpc from '@grpc/grpc-js';
import {connect, Contract, Identity, Signer, signers} from "@hyperledger/fabric-gateway";
import * as crypto from 'crypto';
import { promises as fs } from 'fs';
import * as path from "path";

const mspId = 'Org1MSP';
const channelName = 'userlog-channel';
const chaincodeName = 'mychaincode';

const DIR_PATH = path.resolve(__dirname, '..', '..', '..');
const keyPath = `${DIR_PATH}/organizations/peerOrganizations/userlog-org1.example.com/users/User1@userlog-org1.example.com/msp/keystore/priv_sk`;
const certPath = `${DIR_PATH}/organizations/peerOrganizations/userlog-org1.example.com/users/User1@userlog-org1.example.com/msp/signcerts/User1@userlog-org1.example.com-cert.pem`;
const tlsCertPath = `${DIR_PATH}/organizations/peerOrganizations/userlog-org1.example.com/msp/tlscacerts/tlsca.userlog-org1.example.com-cert.pem`;
const peerEndPoint = 'localhost:7051';
const peerHostAlias = 'peer0.userlog-org1.example.com';

export class Connection {
    public static contract: Contract;
    public init() {
        initFabric();
    }
}

async function initFabric(): Promise<void> {
    const client = await getGrpcClient();

    const gateway = connect({
        client,
        identity: await getIdentity(),
        signer: await getSigner(),
    });

    try {
        const network = gateway.getNetwork(channelName);
        const contract = network.getContract(chaincodeName);
        Connection.contract = contract;
    } catch(e: any) {
        console.log(e)
    } finally {
        // gateway.close();
        // client.close();
    }
}

async function getGrpcClient() : Promise<grpc.Client> {
    const tlsRootCert = await fs.readFile(tlsCertPath);
    const tlsCredentials = grpc.credentials.createSsl(tlsRootCert);
    return new grpc.Client(peerEndPoint, tlsCredentials, {
        'grpc.ssl_target_name_override': peerHostAlias,
    })
}

async function getIdentity(): Promise<Identity> {
    const credentials = await fs.readFile(certPath);
    return {mspId: mspId, credentials};
}

async function getSigner(): Promise<Signer> {
    const privateKeyPem = await fs.readFile(keyPath);
    const privateKey = crypto.createPrivateKey(privateKeyPem);
    return signers.newPrivateKeySigner(privateKey);
}