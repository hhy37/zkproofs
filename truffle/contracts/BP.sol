pragma solidity ^0.4.24;

import "./EC.sol";
import "./Util.sol";
import "./Auxiliar.sol";
import "./Generators.sol";

contract BP {

    EC ec;
    rpCommit public zkCommitRP;
    rpProof public zkproofRP;
    ipProof public zkproofIP;
    
    constructor() public {
	ec = new EC();
    }
	
    struct rpProof {
	uint256 Vx;
	uint256 Vy;
	uint256 Ax;
	uint256 Ay;
	uint256 Sx;
	uint256 Sy;
	uint256 T1x;
	uint256 T1y;
	uint256 T2x;
	uint256 T2y;
	uint256 Taux;
	uint256 Tprime;
	uint256 Mu;
    }

    struct rpCommit {
	uint256 Commitx;
	uint256 Commity;
    }

    struct ipProof {
	uint256[5] Lsx; 
	uint256[5] Lsy; 
	uint256[5] Rsx; 
	uint256[5] Rsy; 
	uint256 Px;
	uint256 Py;
	uint256 A;
	uint256 B;
	uint256 Ux;
	uint256 Uy;
	uint256[32] Hhx;
	uint256[32] Hhy;
    }
    
    function setProofIP(
	    uint256 Px,
	    uint256 Py,
	    uint256 A,
	    uint256 B,
	    uint256 Ux,
	    uint256 Uy
    ) public 
    {
	zkproofIP.Px = Px;
	zkproofIP.Py = Py;
	zkproofIP.A = A;
	zkproofIP.B = B;
	zkproofIP.Ux = Ux;
	zkproofIP.Uy = Uy;
    } 

    function setProofIPArray(
	    uint256 Lsx,
	    uint256 Lsy,
	    uint256 Rsx,
	    uint256 Rsy,
	    uint256 i
    ) public 
    {
	zkproofIP.Lsx[i] = Lsx;
	zkproofIP.Lsy[i] = Lsy;
	zkproofIP.Rsx[i] = Rsx;
	zkproofIP.Rsy[i] = Rsy;
    }
    
    function updateGens(
	    uint256[32] Hhx,
	    uint256[32] Hhy
     ) public 
     {
	hhprimex = Hhx;
	hhprimey = Hhy;
     }

    function setCommitRP(
	    uint256 Commitx,
	    uint256 Commity
    ) public 
    {
	zkCommitRP.Commitx = Commitx;
	zkCommitRP.Commity = Commity;
    }

    function setProofRP(
	    uint256 Vx,
	    uint256 Vy,
	    uint256 Ax,
	    uint256 Ay,
	    uint256 Sx,
	    uint256 Sy,
	    uint256 T1x,
	    uint256 T1y,
	    uint256 T2x,
	    uint256 T2y,
	    uint256 Tprime,
	    uint256 Taux,
	    uint256 Mu
    ) public
    {
	zkproofRP.Vx = Vx;
	zkproofRP.Vy = Vy;
	zkproofRP.Ax = Ax;
	zkproofRP.Ay = Ay;
	zkproofRP.Sx = Sx;
	zkproofRP.Sy = Sy;
	zkproofRP.T1x = T1x;
	zkproofRP.T1y = T1y;
	zkproofRP.T2x = T2x;
	zkproofRP.T2y = T2y;
	zkproofRP.Tprime = Tprime;
	zkproofRP.Taux = Taux;
	zkproofRP.Mu = Mu;
    }


    struct DataIP {
        uint256[32] ngprimex;
        uint256[32] ngprimey;
        uint256[32] ngprime2x;
        uint256[32] ngprime2y;
        uint256[32] ggprimex;
        uint256[32] ggprimey;
        uint256[32] nhprimex;
        uint256[32] nhprimey;
        uint256[32] nhprime2x;
        uint256[32] nhprime2y;
        uint256[32] hhprimex;
        uint256[32] hhprimey;
        uint256 Pprimex;
        uint256 Pprimey;
        uint256 xx;
        uint256 xxinv;
        uint256 xx2;
        uint256 xx2inv;
        uint256 nrhsx;
        uint256 nrhsy;
        uint256 hbx;
        uint256 hby;
        uint256 uabx;
        uint256 uaby;
        uint256 nPx;
        uint256 nPy;
        uint256 Lsx2x;
        uint256 Lsx2y;
        uint256 Rsx2invx;
        uint256 Rsx2invy;
    }
    
    struct Data {
	uint256 Gx;
	uint256 Gy;
	uint256 Hx;
	uint256 Hy;
	uint256[32] Ggx;
	uint256[32] Ggy;
	uint256[32] Hhx;
	uint256[32] Hhy;
    	uint256[32] hprimex;
    	uint256[32] hprimey;
        uint256 i;
    	uint256 y;
   	uint256 z;
   	uint256 x;
        uint256 yinv;
        uint256 expy;
        uint256 z2;
        uint256 x2;
        uint256 lhsx;
        uint256 lhsy;
        uint256 rhsx;
        uint256 rhsy;
        uint256 delta;
        uint256 gdeltax;
        uint256 gdeltay;
        uint256 T1xx;
        uint256 T1xy;
        uint256 T2x2x;
        uint256 T2x2y;
        uint256 Sxx;
        uint256 Sxy;
        uint256 ASx;
        uint256 ASy;
        uint256 mz;
        uint256[32] vmz;
        uint256 gpmzx;
        uint256 gpmzy;
        uint256[32] vz;
        uint256[32] vy;
        uint256[32] zyn;
        uint256[32] p2n;
        uint256[32] z22n;
        uint256[32] zynz22n;
        uint256 lPx;
        uint256 lPy;
        uint256 rPx;
        uint256 rPy;
        uint256 hprimeexpx;
        uint256 hprimeexpy;
    }
        
    uint256[32] hhprimex;
    uint256[32] hhprimey;
    event Log(address id, string s);
        
    function verifyIP(
    ) public constant  
        returns (bool result) {
	uint256 i;
	uint256 nprime;
	uint256 nlast;
	uint256 ab;
	bool c;
	uint256 n;
	n = Generators.getn();
	DataIP memory dt;
	
	dt.ggprimex = Generators.getGgx();
	dt.ggprimey = Generators.getGgy();
	//dt.hhprimex = Generators.getHhx();
	//dt.hhprimey = Generators.getHhy();
	dt.hhprimex = hhprimex;
	dt.hhprimey = hhprimey;
	//hhprimex = Hhx;
	//hhprimey = Hhy;
	dt.Pprimex = zkproofIP.Px;
	dt.Pprimey = zkproofIP.Py;
	nprime = 32;

	for(i=0;i<5;i++) {
	    emit Log(address(0), "OK");
            nlast = nprime;
	    nprime = nprime / 2;
	    (dt.xx,) = Util.hashBP(zkproofIP.Lsx[i], zkproofIP.Lsy[i], zkproofIP.Rsx[i], zkproofIP.Rsy[i]); 
	    dt.xxinv = ec._invF(dt.xx);
	    
	    (dt.ngprimex, dt.ngprimey) = Auxiliar.VectorScalarExp(dt.ggprimex, dt.ggprimey, dt.xxinv, 0, nprime);
	    (dt.ngprime2x, dt.ngprime2y) = Auxiliar.VectorScalarExp(dt.ggprimex, dt.ggprimey, dt.xx, nprime, nlast);
	    (dt.ggprimex, dt.ggprimey) = Auxiliar.VectorECAdd(dt.ngprimex, dt.ngprimey, dt.ngprime2x, dt.ngprime2y, nprime);
	    
	    (dt.nhprimex, dt.nhprimey) = Auxiliar.VectorScalarExp(dt.hhprimex, dt.hhprimey, dt.xx, 0, nprime);
	    (dt.nhprime2x, dt.nhprime2y) = Auxiliar.VectorScalarExp(dt.hhprimex, dt.hhprimey, dt.xxinv, nprime, nlast);
	    (dt.hhprimex, dt.hhprimey) = Auxiliar.VectorECAdd(dt.nhprimex, dt.nhprimey, dt.nhprime2x, dt.nhprime2y, nprime);

	    dt.xx2 = mulmod(dt.xx, dt.xx, n);
	    dt.xx2inv = ec._invF(dt.xx2);
	    (dt.Lsx2x, dt.Lsx2y) = ec.ecmul(zkproofIP.Lsx[i], zkproofIP.Lsy[i], dt.xx2);
	    (dt.Pprimex, dt.Pprimey) = ec.ecadd(dt.Pprimex, dt.Pprimey, dt.Lsx2x, dt.Lsx2y); 
	    (dt.Rsx2invx, dt.Rsx2invy) = ec.ecmul(zkproofIP.Rsx[i], zkproofIP.Rsy[i], dt.xx2inv);
	    (dt.Pprimex, dt.Pprimey) = ec.ecadd(dt.Pprimex, dt.Pprimey, dt.Rsx2invx, dt.Rsx2invy); 
	}

	ab = mulmod(zkproofIP.A, zkproofIP.B, n);

	(dt.nrhsx, dt.nrhsy) = ec.ecmul(dt.ggprimex[0], dt.ggprimey[0], zkproofIP.A);
	(dt.hbx, dt.hby) = ec.ecmul(dt.hhprimex[0], dt.hhprimey[0], zkproofIP.B);
	(dt.nrhsx, dt.nrhsy) = ec.ecadd(dt.nrhsx, dt.nrhsy, dt.hbx, dt.hby);
        (dt.uabx, dt.uaby) = ec.ecmul(zkproofIP.Ux, zkproofIP.Uy, ab); 	
	(dt.nrhsx, dt.nrhsy) = ec.ecadd(dt.nrhsx, dt.nrhsy, dt.uabx, dt.uaby); 

	(dt.nPx, dt.nPy) = ec.neg(dt.Pprimex, dt.Pprimey); 
	(dt.nPx, dt.nPy) = ec.ecadd(dt.nPx, dt.nPy, dt.nrhsx, dt.nrhsy);
	c = ec.isZero(dt.nPx, dt.nPy);
	
	result = c;
    }
	
    function verifyBP(
    ) public constant 
        returns (uint256 result) {

	uint256 i;
	bool ok;
	uint256 n = Generators.getn();
	Data memory dt;
	dt.Gx = Generators.getGx();
	dt.Gy = Generators.getGy();
	dt.Hx = Generators.getHx();
	dt.Hy = Generators.getHy();
	dt.Ggx = Generators.getGgx();
	dt.Ggy = Generators.getGgy();
	dt.Hhx = Generators.getHhx();
	dt.Hhy = Generators.getHhy();

	(dt.y,dt.z) = Util.hashBP(zkproofRP.Ax, zkproofRP.Ay, zkproofRP.Sx, zkproofRP.Sy);
	(dt.x, ) = Util.hashBP(zkproofRP.T1x, zkproofRP.T1y, zkproofRP.T2x, zkproofRP.T2y);

	dt.yinv = ec._invF(dt.y);
	dt.expy = dt.yinv;
	dt.hprimex[0] = dt.Hhx[0];
	dt.hprimey[0] = dt.Hhy[0];
	for (i=1;i<32;i++) {
		(dt.hprimex[i], dt.hprimey[i]) = ec.ecmul(dt.Hhx[i], dt.Hhy[i], dt.expy);
		dt.expy = mulmod(dt.expy, dt.yinv, n);
	}

	// CommitG1
	(dt.lhsx, dt.lhsy) = Auxiliar.pedersen(zkproofRP.Tprime, zkproofRP.Taux);

	dt.z2 = mulmod(dt.z,dt.z,n);
	dt.x2 = mulmod(dt.x,dt.x,n);

	(dt.rhsx, dt.rhsy) = ec.ecmul(zkproofRP.Vx, zkproofRP.Vy, dt.z2);
	(dt.delta) = Auxiliar.Delta(dt.y,dt.z);

	(dt.gdeltax, dt.gdeltay) = ec.ecmul(dt.Gx, dt.Gy, dt.delta);

	(dt.rhsx, dt.rhsy) = ec.ecadd(dt.rhsx, dt.rhsy, dt.gdeltax, dt.gdeltay);

	(dt.T1xx, dt.T1xy) = ec.ecmul(zkproofRP.T1x, zkproofRP.T1y, dt.x);
	(dt.T2x2x, dt.T2x2y) = ec.ecmul(zkproofRP.T2x, zkproofRP.T2y, dt.x2);

	(dt.rhsx, dt.rhsy) = ec.ecadd(dt.rhsx, dt.rhsy, dt.T1xx, dt.T1xy);
	(dt.rhsx, dt.rhsy) = ec.ecadd(dt.rhsx, dt.rhsy, dt.T2x2x, dt.T2x2y);

	(dt.lhsx, dt.lhsy) = ec.neg(dt.lhsx, dt.lhsy);
	(dt.rhsx, dt.rhsy) = ec.ecadd(dt.rhsx, dt.rhsy, dt.lhsx, dt.lhsy);
	// Condition 65
	ok = ec.isZero(dt.rhsx, dt.rhsy);
	if (!ok) {
		result = 65;
		//h = 65;
		return;
	}

	/////////////////////////////////////////////////////////////////////////////

	(dt.Sxx, dt.Sxy) = ec.ecmul(zkproofRP.Sx, zkproofRP.Sy, dt.x);
	(dt.ASx, dt.ASy) = ec.ecadd(zkproofRP.Ax, zkproofRP.Ay, dt.Sxx, dt.Sxy);
	
	dt.mz = n - dt.z;
	dt.vmz = Auxiliar.VectorCopy(dt.mz);
	(dt.gpmzx, dt.gpmzy) = Auxiliar.VectorExp(dt.Ggx, dt.Ggy, dt.vmz);

	dt.vz = Auxiliar.VectorCopy(dt.z);
	dt.vy = Auxiliar.PowerOf(dt.y);
        dt.zyn = Auxiliar.VectorMul(dt.vy, dt.vz);	

	dt.p2n = Auxiliar.PowerOf(2);
	dt.z22n = Auxiliar.VectorScalarMul(dt.p2n, dt.z2);

	dt.zynz22n = Auxiliar.VectorAdd(dt.zyn, dt.z22n);

	(dt.lPx, dt.lPy) = ec.ecadd(dt.ASx, dt.ASy, dt.gpmzx, dt.gpmzy);

	(dt.hprimeexpx, dt.hprimeexpy) = Auxiliar.VectorExp(dt.hprimex, dt.hprimey, dt.zynz22n);

	(dt.lPx, dt.lPy) = ec.ecadd(dt.lPx, dt.lPy, dt.hprimeexpx, dt.hprimeexpy);

	/////////////////////////////////////////////////////////////////////////////
	
	(dt.rPx, dt.rPy) = ec.ecmul(dt.Hx, dt.Hy, zkproofRP.Mu);
	(dt.rPx, dt.rPy) = ec.ecadd(dt.rPx, dt.rPy, zkCommitRP.Commitx, zkCommitRP.Commity);
	
	(dt.lPx, dt.lPy) = ec.neg(dt.lPx, dt.lPy);
	(dt.rPx, dt.rPy) = ec.ecadd(dt.rPx, dt.rPy, dt.lPx, dt.lPy);
	// Condition 67
	ok = ec.isZero(dt.rPx, dt.rPy);
	if (!ok) {
		result = 67;
		//h = 67;
		return;
	}

	/////////////////////////////////////////////////////////////////////////////

	/*ok = verifyIP();
	if (!ok) {
		result = 69;
		return;
	}*/
	result = 1;
    }
}

