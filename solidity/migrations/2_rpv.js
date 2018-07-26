var rpv = artifacts.require("./RangeProofValidator.sol");

module.exports = function(deployer) {
  deployer.deploy(rpv);
};
