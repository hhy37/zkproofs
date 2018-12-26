require('babel-register');
require('babel-polyfill');

module.exports = {
    networks: {
        development: {
            host: 'localhost',
            port: 8545,
            network_id: '*',
            gas: 300000000,
        },
        coverage: {
            host: 'localhost',
            port: 8555,
            network_id: '*',
            gas: 0xffffffff,
        },
    },
    solc: {
        optimizer: {
            enabled: true,
            runs: 200
        }
    },
    mocha: {
        reporter: 'eth-gas-reporter',
        reporterOptions : {
        	currency: 'EUR',
        	gasPrice: 1
    	}
    }
};
