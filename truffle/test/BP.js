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
    
    it('should verify the BP proof', async function () {
        await bp.setProofRP(
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
		new BigNumber(proof.Mu, 10)
		);
        await bp.setCommitRP(
		new BigNumber(proof.Commit.X, 10),
		new BigNumber(proof.Commit.Y, 10)
		);
	/*var i;
	await bp.setProofIP(	
		new BigNumber(proof.Proofip.P.X, 10),
		new BigNumber(proof.Proofip.P.Y, 10),
		new BigNumber(proof.Proofip.A, 10),
		new BigNumber(proof.Proofip.B, 10),
		new BigNumber(proof.Proofip.U.X, 10),
		new BigNumber(proof.Proofip.U.Y, 10)
	);
	for (i=0;i<5;i++) {
		await bp.setProofIPArray(
			new BigNumber(proof.Proofip.Ls[i].X, 10),
			new BigNumber(proof.Proofip.Ls[i].Y, 10),
			new BigNumber(proof.Proofip.Rs[i].X, 10),
			new BigNumber(proof.Proofip.Rs[i].Y, 10),
			i 
		);
	}*/
	/*var uHx = [];
	var uHy = [];
	for (i=0;i<32;i++) {
		uHx[i] = new BigNumber(setup.Zkip.Hh[i].X, 10);
		uHy[i] = new BigNumber(setup.Zkip.Hh[i].Y, 10);
	}
	await bp.updateGens(
		uHx,
		uHy		
	);*/
        var result = await bp.verifyBP( { gas: 130000000 } );
	log("result="+result);
	//log("result0="+result[1][0].toString(10));
    });
    
    it('should verify the IP proof', async function () {
	var i;
	await bp.setProofIP(	
		new BigNumber(proof.Proofip.P.X, 10),
		new BigNumber(proof.Proofip.P.Y, 10),
		new BigNumber(proof.Proofip.A, 10),
		new BigNumber(proof.Proofip.B, 10),
		new BigNumber(proof.Proofip.U.X, 10),
		new BigNumber(proof.Proofip.U.Y, 10)
	);
	for (i=0;i<5;i++) {
		await bp.setProofIPArray(
			new BigNumber(proof.Proofip.Ls[i].X, 10),
			new BigNumber(proof.Proofip.Ls[i].Y, 10),
			new BigNumber(proof.Proofip.Rs[i].X, 10),
			new BigNumber(proof.Proofip.Rs[i].Y, 10),
			i
		);
	}
	var uHx = [];
	var uHy = [];
	for (i=0;i<32;i++) {
		uHx[i] = new BigNumber(setup.Zkip.Hh[i].X, 10);
		uHy[i] = new BigNumber(setup.Zkip.Hh[i].Y, 10);
	}
	await bp.updateGens(
		uHx,
		uHy		
	);

        var result = await bp.verifyIP( { gas: 200000000 } );
	log("result="+result);
	/*log("result="+result[0]);
	log("result0="+result[1][0].toString(10));
	log("result1="+result[1][1].toString(10));
	log("result2="+result[1][2].toString(10));
	log("result3="+result[1][3].toString(10));
	log("result4="+result[1][4].toString(10));
	log("result5="+result[1][5].toString(10));
	log("result6="+result[1][6].toString(10));*/
    });
});
