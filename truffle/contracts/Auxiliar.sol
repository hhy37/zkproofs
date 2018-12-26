pragma solidity ^0.4.24;

import "./EC.sol";
import "./Generators.sol";

library Auxiliar {
    
    function pedersen(
	    uint256 x, 
	    uint256 r
    ) public
    	returns (uint256 cx, uint256 cy) {
	uint256 resx;
	uint256 resy;
	uint256 Gx;
	uint256 Gy;
	uint256 Hx; 
	uint256 Hy; 
	EC ec = new EC();
	Gx = Generators.getGx();
	Gy = Generators.getGy();
	Hx = Generators.getHx();
	Hy = Generators.getHy();
	(cx,cy) = ec.ecmul(Gx, Gy, x);
	(resx, resy) = ec.ecmul(Hx, Hy, r);
	(cx, cy) = ec.ecadd(cx, cy, resx, resy);
    }

    function PowerOf(
	    uint256 x
    ) public pure  
    	returns (uint256[32] memory res) {
	uint256 current = 1;
	uint256 i;
	uint256 n;
        n = Generators.getn();	
	for (i=0;i<32;i++){
		res[i] = current;
		current = mulmod(current, x, n);
	}
    } 

    function VectorECAdd(
	    uint256[32] memory ax,
	    uint256[32] memory ay,
	    uint256[32] memory bx,
	    uint256[32] memory by,
	    uint256 half
    ) public returns (uint256[32] memory resx, uint256[32] memory resy) 
    {
	uint256 i;
	EC ec = new EC();
	for (i=0;i<half;i++) {
	    (resx[i], resy[i]) = ec.ecadd(ax[i], ay[i], bx[i], by[i]);
	}
    }

    function VectorScalarExp(
	    uint256[32] memory ax,
	    uint256[32] memory ay,
	    uint256 b,
	    uint256 half,
	    uint256 length
    ) public 
    	returns (uint256[32] memory resx, uint256[32] memory resy) 
    {
	uint256 i;
	uint256 j=0;
	EC ec = new EC();
	for (i=half;i<length;i++) {
	    (resx[j], resy[j]) = ec.ecmul(ax[i], ay[i], b);
	    j++;
	}
    }

    function VectorAdd(
	    uint256[32] memory a,
	    uint256[32] memory b
    ) public pure  
    	returns (uint256[32] memory res) {
	uint256 i;
	uint256 n;
	n = Generators.getn();
	for (i=0;i<32;i++) {
	    res[i] = addmod(a[i], b[i], n);
	}
    }

    function VectorScalarMul(
	    uint256[32] memory a,
	    uint256 b
    ) public pure  
    	returns (uint256[32] memory res) {
	uint256 i;
	uint256 n;
	n = Generators.getn();
	for (i=0;i<32;i++) {
	    res[i] = mulmod(a[i], b, n);
	}
    }

    function VectorMul(
	    uint256[32] memory a,
	    uint256[32] memory b
    ) public pure 
    	returns (uint256[32] memory res) {
	uint256 i;
	uint256 n;
	n = Generators.getn();
	for (i=0;i<32;i++) {
	    res[i] = mulmod(a[i], b[i], n);
	}
    }

    function VectorExp(
	    uint256[32] memory ax,
	    uint256[32] memory ay,
	    uint256[32] memory e
    ) public 
    	returns (uint256 resx, uint256 resy) {
	uint256 i;
	uint256 auxx;
	uint256 auxy;
	EC ec = new EC();
	(resx, resy) = ec.setInfinity();
	for (i=0; i<32; i++) {
	    (auxx, auxy) = ec.ecmul(ax[i], ay[i], e[i]);
	    (resx, resy) = ec.ecadd(resx, resy, auxx, auxy);
	}
    }
    	
    function VectorCopy(
	    uint256 x
    ) public pure 
    	returns (uint256[32] memory c) {
	uint256 i;
	for (i=0;i<32;i++) {
		c[i] = x;
	}
    }

    function ScalarProduct(
	    uint256[32] memory x,
	    uint256[32] memory y
    ) public pure  
    	returns (uint256 res) {
	uint256 i;
	uint256 n;
	n = Generators.getn();
	res = 0;
	for(i=0;i<32;i++){
	    res = addmod(res, mulmod(x[i], y[i], n), n);
	}
    }

    function submod(
	    uint256 x,
	    uint256 y,
	    uint256 n
    ) public pure  
    returns (uint256 res) {
	if (x > y) {
	    res = x - y;
	} else {
	    res = n - y + x;
	    //res = res + x;
	}

    }

    function Delta(
	    uint256 y, 
	    uint256 z
    ) public pure 
    	returns (uint256 delta) {
	uint256 z2;
	uint256 z3;	
	uint256[32] memory v1;
	uint256[32] memory vy;
	uint256[32] memory p2n;
	uint256 sp1y;
	uint256 sp12;
	uint256 z3sp12;
	uint256 n;
	n = Generators.getn();

	z2 = mulmod(z, z, n);
	z3 = mulmod(z2, z, n);
	v1 = VectorCopy(1);
	vy = PowerOf(y);
	sp1y = ScalarProduct(v1, vy);

	p2n = PowerOf(2);
	sp12 = ScalarProduct(v1, p2n);

	delta = submod(z, z2, n);
       	delta = mulmod(delta, sp1y, n);
	z3sp12 = mulmod(z3, sp12, n);
	delta = submod(delta, z3sp12, n);
    }
}
