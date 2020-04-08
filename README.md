# Cardano staking

## Overview
Run on a VPS a cardano node: 
- Network: testnet Shelley
- Node code version: Jormungandr
- Join cluster nightly [config](https://hydra.iohk.io/build/2156729/download/1/index.html)
- With staking pool capabilities

## Deploy
### Install node for staking pool
- Tuto [here](https://github.com/input-output-hk/shelley-testnet/blob/master/docs/stake_pool_operator_how_to.md)
or [here](https://github.com/Chris-Graffagnino/Jormungandr-for-Newbs/blob/master/docs/jormungandr_node_setup_guide.md)
- Create VM in aws (ubuntu ram:4BG, disk:100GB)
- Connect: `ssh -i ~/.ssh/aws-finstack-greg-user.pem ubuntu@52.31.216.140
`
- Install soft:
```
mkdir cardano
cd cardano
wget https://github.com/input-output-hk/jormungandr/releases/download/v0.8.16/jormungandr-v0.8.16-x86_64-unknown-linux-gnu-generic.tar.gz
tar xvf jormungandr-v0.8.16-x86_64-unknown-linux-gnu-generic.tar.gz
./jcli -V
./jormungandr -V
nano stakepool-config.yaml <-- replace 0.0.0.0 with your public IP
```

Run node in a screen:
```
screen -R 
./jormungandr --genesis-block-hash $(cat genesis-hash.txt) --config ./stakepool-config.yaml
```


### Reconnect to a running node
- Connect: `ssh -i ~/.ssh/aws-finstack-greg-user.pem ubuntu@34.248.53.21`
- Screen attach: `screen -r` 
- Change screen: `CTRL + A then Space`
- Check status: `./jcli rest v0 node stats get --host "http://127.0.0.1:3100/api"`
- `echo addr1s45xkmwmt7ek7uc0zund6v60av8hvsrm8k2pruw8j2mmx3468nngyyycmmw > account.txt`
- Check balance: `./jcli rest v0 account get $ACCOUNT_ADDRESS -h http://127.0.0.1:3100/api` or `./jcli rest v0 account get $(cat account.txt) -h http://127.0.0.1:3100/api`

- Test Pool server:
```
PRIVATE_KEY_SK: ed25519e_sk1zq22j3845fph5hgnyqvd7kr0y08cytyvk8mq99dyn52y9u57paz6he3sxxl5vwtvrm8wlklctsehrfgzj94q6ptpqtf7t70em6agehchrcucg
PUBLIC_KEY_PK:  ed25519_pk1dp4kmk6lkdhhxrchymwnxnltpamyq7eajsglr3ujk7e5dw3uu6pqm3xwwj
ADDRESS:        addr1s45xkmwmt7ek7uc0zund6v60av8hvsrm8k2pruw8j2mmx3468nngyyycmmw
```

### Error:

```
Apr 06 19:15:37.321 INFO receiving from network bytes=1.66mb 278.64kb/s, blockchain 75703415-0006d40c-683.1183, peer_addr: 52.8.169.161:3000, task: bootstrap
Apr 06 19:15:44.310 INFO receiving from network bytes=1.66mb 243.13kb/s, blockchain 3a4322de-0006ddd0-686.6060, peer_addr: 52.8.169.161:3000, task: bootstrap
Apr 06 19:15:51.263 INFO receiving from network bytes=1.66mb 244.39kb/s, blockchain 174e80c3-0006e794-690.4860, peer_addr: 52.8.169.161:3000, task: bootstrap
Apr 06 19:15:52.536 INFO switching branch from 9409af11-00000000-0.0 to a90d4fcb-0006e952-691.2702, peer_addr: 52.8.169.161:3000, task: bootstrap
Apr 06 19:15:52.539 INFO initial bootstrap completed, peer_addr: 52.8.169.161:3000, task: bootstrap
Apr 06 19:15:52.540 INFO listening and accepting gRPC connections, local_addr: 34.248.53.21:3000, task: network
Apr 06 19:15:52.540 ERRO failed to listen for P2P connections at 34.248.53.21:3000, reason: failed to listen for connections on 34.248.53.21:3000: Cannot assign requested address (os error 99), task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: fe3332044877b2034c8632a08f08ee47f3fbea6c64165b3b, peer_addr: 13.230.137.72:3000, task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: 3d1f8891bf53eb2946a18fb46cf99309649f0163b4f71b34, peer_addr: 52.52.67.33:3000, task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: fdb88d08c7c759b5d30e854492cb96f8203c2d875f6f3e00, peer_addr: 184.169.162.15:3000, task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: c38aabb936944776ef15bbe4b5b02454c46a8a80d871f873, peer_addr: 13.230.48.191:3000, task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: 7e2222179e4f3622b31037ede70949d232536fdc244ca3d9, peer_addr: 18.196.168.220:3000, task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: f131b71d65c49116f3c23c8f1dd7ceaa98f5962979133404, peer_addr: 18.184.181.30:3000, task: network
Apr 06 19:15:52.540 INFO connecting to peer, node_id: 9085fa5caeb39eace748a7613438bd2a62c8c8ee00040b71, peer_addr: 3.124.132.123:3000, task: network
Apr 06 19:15:52.542 INFO service finished with error, task: network
Apr 06 19:15:52.542 INFO create new branch with tip 9409af11-00000000-0.0 | current-tip a90d4fcb-0006e952-691.2702, task: block
Apr 06 19:15:52.542 CRIT Service has terminated with an error
A service has terminated with an error
```

## ANNEXE (don't use)

Infra on AWS:
- With [github](https://github.com/input-output-hk/jormungandr)
 or [tuto](https://testnets.cardano.org/en/cardano/shelley/get-started/setting-up-a-self-node/)
- cardano-node-test `ssh -i ~/.ssh/aws-finstack-greg-user.pem ubuntu@34.248.53.21`

```
sudo apt-get update -y
sudo apt install -y build-essential pkg-config libssl-dev 

git clone --recurse-submodules https://github.com/input-output-hk/jormungandr
cd jormungandr
git checkout tags/v0.8.17
git submodule update
cargo install --locked --path jormungandr
```

### Cardano in docker
- With [tuto](https://github.com/redoracle/jormungandr)
- Connect to VM cardano-node-test-docker: `ssh -i ~/.ssh/aws-finstack-greg-user.pem ubuntu@3.249.165.38`
- run:
```
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt-get update
apt-cache policy docker-ce
sudo apt-get install -y docker-ce
sudo systemctl status docker
sudo usermod -aG docker ${USER}
su - ${USER}
docker ps
sudo usermod -aG docker ${USER}
docker ps

```


```
git clone --recurse-submodules https://github.com/input-output-hk/jormungandr
cd jormungandr
git checkout tags/v0.8.17
git submodule update
cd docker
docker build -t jormungandr-node:0.8.17 --build-arg VER=v0.8.17 .
docker run -it -d --name Cardano -p 3000:3000 -p 8299:8299 -p 127.0.0.1:3101:3101 -v /home/ubuntu/DATA/CardanoNodeTest/:/datak redoracle/jormungandr

```
