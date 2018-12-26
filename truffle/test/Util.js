
var proof = {
    "A": {
        "X": "110720467414728166769654679803728202169916280248550137472490865118702779748947",
        "Y": "103949684536896233354287911519259186718323435572971865592336813380571928560949"
    },
    "S": {
        "X": "78662919066140655151560869958157053125629409725243565127658074141532489435921",
        "Y": "114946280626097680211499478702679495377587739951564115086530426937068100343655"
    },
};

const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();
const Util = artifacts.require('Util');
    
var verbose = true;
function log (S) {
    if (verbose) {
        console.log(S);
    }
}

contract('Util', async function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    const gx = new BigNumber('79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798', 16);
    const gy = new BigNumber('483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8', 16);
    const agx = new BigNumber(proof.A.X, 10);
    const agy = new BigNumber(proof.A.Y, 10);
    const sgx = new BigNumber(proof.S.X, 10);
    const sgy = new BigNumber(proof.S.Y, 10);

    var util;
    before(async function () {
        util = await Util.new();
    });
    
    /*it('should compute sha256', async function () {
	var res = await util.hashBP(agx, agy, sgx, sgy);
        log('res[0]: ' + res[0].toString(10));
        log('res[1]: ' + res[1].toString(10));
	    assert.equal(res[0].toString(10), '103823382860325249552741530200099120077084118788867728791742258217664299339569', "not equal");
	    assert.equal(res[1].toString(10), '8192372577089859289404358830067912230280991346287696886048261417244724213964', "not equal");
    });
    
    it('should compute sha256 on gx,gy', async function () {
	var res = await util.hashBP(gx, gy, gx, gy);
        log('res[0]: ' + res[0].toString(10));
        log('res[1]: ' + res[1].toString(10));
	assert.equal(res[0].toString(10), '11897424191990306464486192136408618361228444529783223689021929580052970909263', "not equal"); 
	assert.equal(res[1].toString(10), '22166487799255634251145870394406518059682307840904574298117500050508046799269', "not equal"); 
    });*/

});
