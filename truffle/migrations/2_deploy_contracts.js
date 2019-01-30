const EC = artifacts.require('EC');
const Generators = artifacts.require('Generators');
const Auxiliar = artifacts.require('Auxiliar');
const Util = artifacts.require('Util');
const BP = artifacts.require('BP');

module.exports = async function (deployer) {
    deployer.deploy(EC);
    deployer.deploy(Generators);
    deployer.deploy(Util);
    deployer.link(Generators, Auxiliar);
    deployer.link(EC, Auxiliar);
    deployer.deploy(Auxiliar);
    deployer.link(EC, BP);
    deployer.link(Generators, BP);
    deployer.link(Auxiliar, BP);
    deployer.link(Util, BP);
    deployer.deploy(BP);
};
