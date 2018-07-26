touch /tmp/empty
../go-ethereum/build/bin/geth --datadir ~/ethereum/data init ~/git/zkrangeproof/data/genesis.json
../go-ethereum/build/bin/geth --datadir ~/ethereum/data --password /tmp/empty account new
