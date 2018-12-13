touch /tmp/empty
../go-ethereum/build/bin/geth --datadir ~/ethereum/data --targetgaslimit 99900000000 --mine --maxpeers 0 --networkid 15997 --nodiscover  --rpc --rpcaddr 0.0.0.0 --rpcport 8545 --rpccorsdomain "*" --unlock 0 --password /tmp/empty --rpcapi "eth,net,web3,debug" console
