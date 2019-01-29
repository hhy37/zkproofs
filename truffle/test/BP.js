/* Unit tests for Bulletproofs verification smar contract
 *
 *
 * */
var fs=require('fs');
var data=fs.readFileSync('proof.dat', 'utf8');
var datas=fs.readFileSync('setup.dat', 'utf8');
var proof=JSON.parse(data);
var setup=JSON.parse(datas);
console.log(proof);
console.log(setup);

const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

const BP = artifacts.require('BP');

var verbose = true;
function log (S) {
    if (verbose) {
        console.log(S);
    }
}

contract('BP', async function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    var bp;
    before(async function () {
        bp = await BP.new();
    });


	// =============== BP =========================================================

    
    it('should verify the BP+IP proof', async function () {

		var uHx = [];
		var uHy = [];
		for (i=0;i<32;i++) {
			uHx[i] = new BigNumber(setup.Zkip.Hh[i].X, 10);
			uHy[i] = new BigNumber(setup.Zkip.Hh[i].Y, 10);
		}

		let proofIPArray = [];
		for (let i = 0; i < 5; i++) {
				proofIPArray[i*4    ] = new BigNumber(proof.Proofip.Ls[i].X, 10);
				proofIPArray[i*4 + 1] = new BigNumber(proof.Proofip.Ls[i].Y, 10);
				proofIPArray[i*4 + 2] = new BigNumber(proof.Proofip.Rs[i].X, 10);
				proofIPArray[i*4 + 3] = new BigNumber(proof.Proofip.Rs[i].Y, 10);
		}

        var result = await bp.verifyBP(
        	// bpargs
        	[
				new BigNumber(proof.V.X, 10),
				new BigNumber(proof.V.Y, 10),
				new BigNumber(proof.A.X, 10),
				new BigNumber(proof.A.Y, 10),
				new BigNumber(proof.S.X, 10),
				new BigNumber(proof.S.Y, 10),
				new BigNumber(proof.T1.X, 10),
				new BigNumber(proof.T1.Y, 10),
				new BigNumber(proof.T2.X, 10),
				new BigNumber(proof.T2.Y, 10),
				new BigNumber(proof.Tprime, 10),
				new BigNumber(proof.Taux, 10),
				new BigNumber(proof.Mu, 10),
				new BigNumber(proof.Commit.X, 10),
				new BigNumber(proof.Commit.Y, 10)
			],
			// ipargs
			[
				new BigNumber(proof.Proofip.P.X, 10),
				new BigNumber(proof.Proofip.P.Y, 10),
				new BigNumber(proof.Proofip.A, 10),
				new BigNumber(proof.Proofip.B, 10),
				new BigNumber(proof.Proofip.U.X, 10),
				new BigNumber(proof.Proofip.U.Y, 10)
			],
			// hhprimex and y
			uHx,
			uHy,
			// proofIPArray
			proofIPArray,
			{ gas: 2000000000 } );
		log("result="+result);
    });

    // =============== IP =========================================================


	it('should verify the IP proof', async function () {

		// Setup
		var uHx = [];
		var uHy = [];
		for (i=0;i<32;i++) {
			uHx[i] = new BigNumber(setup.Zkip.Hh[i].X, 10);
			uHy[i] = new BigNumber(setup.Zkip.Hh[i].Y, 10);
		}

		let proofIPArray = [];
		for (let i = 0; i < 5; i++) {
			proofIPArray[i*4    ] = new BigNumber(proof.Proofip.Ls[i].X, 10);
			proofIPArray[i*4 + 1] = new BigNumber(proof.Proofip.Ls[i].Y, 10);
			proofIPArray[i*4 + 2] = new BigNumber(proof.Proofip.Rs[i].X, 10);
			proofIPArray[i*4 + 3] = new BigNumber(proof.Proofip.Rs[i].Y, 10);
		}

        var result = await bp.verifyIP([
			new BigNumber(proof.Proofip.P.X, 10),
			new BigNumber(proof.Proofip.P.Y, 10),
			new BigNumber(proof.Proofip.A, 10),
			new BigNumber(proof.Proofip.B, 10),
			new BigNumber(proof.Proofip.U.X, 10),
			new BigNumber(proof.Proofip.U.Y, 10)],

			uHx,
			uHy,

			proofIPArray,
        	{ gas: 300000000000 } );
		bp.Log({}).watch((error, result) => {
		  log(error);
		  log(result);
		})
		log("result="+result);
        assert.equal(result, true, "Invalid result");
    });

});
