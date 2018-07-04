// Copyright 2018 ING Bank N.V.
// This file is part of the go-ethereum library.
//
// The go-ethereum library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// The go-ethereum library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.

/*
This file contains the implementation of the Bulletproofs scheme proposed in the paper:
Bulletproofs: Short Proofs for Confidential Transactions and More
Benedikt Bunz, Jonathan Bootle, Dan Boneh, Andrew Poelstra, Pieter Wuille and Greg Maxwell
Asiacrypt 2008
*/

package zkrangeproof

import (
	"math"
	"math/big"
	"crypto/rand"
	"github.com/ing-bank/zkrangeproof/go-ethereum/crypto/bn256"
	"crypto/sha256"
	"github.com/ing-bank/zkrangeproof/go-ethereum/byteconversion"
	"errors"
	"fmt"
)

/*
Bulletproofs parameters.
*/
type bp struct {
	n int64
	G *bn256.G1
	H *bn256.G1
	g []*bn256.G1  
	h []*bn256.G1  
}

/*
Bulletproofs proof.
*/
type proofBP struct {
	V *bn256.G1
	A *bn256.G1
	S *bn256.G1
	T1 *bn256.G1
	T2 *bn256.G1
	taux *big.Int
	mu *big.Int
	tprime *big.Int
	br []*big.Int
	bl []*big.Int
}
 
/*
vectorCopy returns a vector composed by copies of a.
*/
func VectorCopy(a *big.Int, n int64) ([]*big.Int, error) {
	var (
		i int64
		result []*big.Int
	)
	result = make([]*big.Int, n)
	i = 0
	for i<n {
		result[i] = a
		i = i + 1
	}
	return result, nil
}

/*
vectorCopy returns a vector composed by copies of a.
*/
func VectorG1Copy(a *bn256.G1, n int64) ([]*bn256.G1, error) {
	var (
		i int64
		result []*bn256.G1
	)
	result = make([]*bn256.G1, n)
	i = 0
	for i<n {
		result[i] = a
		i = i + 1
	}
	return result, nil
}

/*
VectorConvertToBig converts an array of int64 to an array of big.Int.
*/
func VectorConvertToBig(a []int64, n int64) ([]*big.Int, error) {
	var (
		i int64
		result []*big.Int
	)
	result = make([]*big.Int, n)
	i = 0
	for i<n {
		result[i] = new(big.Int).SetInt64(a[i])
		i = i + 1
	}
	return result, nil
}

/*
VectorAdd computes vector addition componentwisely.
*/
func VectorAdd(a, b []*big.Int) ([]*big.Int, error) {
	var (
		result []*big.Int
		i,n,m int64
	)
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return nil, errors.New("Size of first argument is different from size of second argument.")
	}
	i = 0
	result = make([]*big.Int, n)
	for i<n {
		result[i] = Add(a[i], b[i])	
		result[i] = Mod(result[i], bn256.Order) 
		i = i + 1
	}
	return result, nil
}

/*
VectorSub computes vector addition componentwisely.
*/
func VectorSub(a, b []*big.Int) ([]*big.Int, error) {
	var (
		result []*big.Int
		i,n,m int64
	)
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return nil, errors.New("Size of first argument is different from size of second argument.")
	}
	i = 0
	result = make([]*big.Int, n)
	for i<n {
		result[i] = Sub(a[i], b[i])	
		result[i] = Mod(result[i], bn256.Order) 
		i = i + 1
	}
	return result, nil
}

/*
VectorScalarMul computes vector scalar multiplication componentwisely.
*/
func VectorScalarMul(a []*big.Int, b *big.Int) ([]*big.Int, error) {
	var (
		result []*big.Int
		i,n int64
	)
	n = int64(len(a))
	i = 0
	result = make([]*big.Int, n)
	for i<n {
		result[i] = Multiply(a[i], b)	
		result[i] = Mod(result[i], bn256.Order) 
		i = i + 1
	}
	return result, nil
}

/*
VectorMul computes vector multiplication componentwisely.
*/
func VectorMul(a, b []*big.Int) ([]*big.Int, error) {
	var (
		result []*big.Int
		i,n,m int64
	)
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return nil, errors.New("Size of first argument is different from size of second argument.")
	}
	i = 0
	result = make([]*big.Int, n)
	for i<n {
		result[i] = Multiply(a[i], b[i])	
		result[i] = Mod(result[i], bn256.Order) 
		i = i + 1
	}
	return result, nil
}

/*
VectorECMul computes vector EC addition componentwisely.
*/
func VectorECAdd(a,b []*bn256.G1) ([]*bn256.G1, error) {
	var (
		result []*bn256.G1
		i,n,m int64
	)
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return nil, errors.New("Size of first argument is different from size of second argument.")
	}
	result = make([]*bn256.G1, n)
	i = 0
	for i<n {
		result[i] = a[i].Add(a[i], b[i])	
		i = i + 1
	}
	return result, nil
}
/*
ScalarProduct return the inner product between a and b.
*/
func ScalarProduct(a, b []*big.Int) (*big.Int, error) {
	var (
		result *big.Int
		i,n,m int64
	)
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return nil, errors.New("Size of first argument is different from size of second argument.")
	}
	i = 0
	result = GetBigInt("0")
	for i<n {
		ab := Multiply(a[i], b[i])	
		result.Add(result, ab)	
		result = Mod(result, bn256.Order) 
		i = i + 1
	}
	return result, nil
}

/*
VectorExp computes Prod_i^n{a[i]^b[i]}.
*/
func VectorExp(a []*bn256.G1, b []*big.Int) (*bn256.G1, error) {
	var (
		result *bn256.G1
		i,n,m int64
	)
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return nil, errors.New("Size of first argument is different from size of second argument.")
	}
	i = 0
	result = new(bn256.G1).SetInfinity()
	for i<n {
		apb := new(bn256.G1).ScalarMult(a[i], b[i])	
		result.Add(result, apb)	
		i = i + 1
	}
	return result, nil
}

/*
VectorScalarExp computes a[i]^b for each i.
*/
func VectorScalarExp(a []*bn256.G1, b *big.Int) ([]*bn256.G1, error) {
	var (
		result []*bn256.G1
		i,n int64
	)
	n = int64(len(a))
	result = make([]*bn256.G1, n)
	i = 0
	for i<n {
		result[i] = new(bn256.G1).ScalarMult(a[i], b)	
		i = i + 1
	}
	return result, nil
}

/*

*/
func VectorScalarProduct(a, b [][]*big.Int) {
	
}

/*
PowerOf returns a vector composed by powers of x.
*/
func PowerOf(x *big.Int, n int64) ([]*big.Int, error) {
	var (
		i int64
		result []*big.Int
	)
	result = make([]*big.Int, n)
	current := GetBigInt("1")
	i = 0
	for i<n {
		result[i] = current 
		current = Multiply(current, x)
		current = Mod(current, bn256.Order) 
		i = i + 1
	}
	return result, nil
}

/*
aR = aL - 1^n
*/
func ComputeAR(x []int64) ([]int64, error) {
	var (
		i int64
		result []int64
	)
	result = make([]int64, len(x))
	i = 0
	for i<int64(len(x)) {
		if x[i] == 0 {
			result[i] = -1 
		} else if x[i] == 1 {
			result[i] = 0 
		} else {
			return nil, errors.New("input contains non-binary element") 
		}
		i = i + 1
	}
	return result, nil
}

/*
Hash is responsible for the computing a Zp element given elements from GT and G1.
*/
func HashBP(A, S *bn256.G1) (*big.Int, *big.Int, error) {
	digest1 := sha256.New()
	digest1.Write([]byte(A.String()))
	digest1.Write([]byte(S.String()))
	output1 := digest1.Sum(nil)
	tmp1 := output1[0: len(output1)]
	result1, err1 := byteconversion.FromByteArray(tmp1)
	
	digest2 := sha256.New()
	digest2.Write([]byte(S.String()))
	digest2.Write([]byte(A.String()))
	output2 := digest2.Sum(nil)
	tmp2 := output2[0: len(output2)]
	result2, err2 := byteconversion.FromByteArray(tmp2)
	
	if err1 != nil {
		return nil, nil, err1
	} else if err2 != nil {
		return nil, nil, err2
	}
	return result1, result2, nil
}

/*
Commitvector computes a commitment to the bit of the secret. 
TODO: Maybe the common interface could have Commit method, but must take care of the different 
secret types though...
*/
func CommitVector(aL,aR []int64, alpha *big.Int, G,H *bn256.G1, g,h []*bn256.G1, n int64) (*bn256.G1, error) {
	var (
		i int64
		R *bn256.G1
	)
	// Compute h^alpha.vg^aL.vh^aR
	R = new(bn256.G1).ScalarMult(H, alpha)
	i = 0
	for i<n {
		gaL := new(bn256.G1).ScalarMult(g[i], new(big.Int).SetInt64(aL[i]))
		haR := new(bn256.G1).ScalarMult(h[i], new(big.Int).SetInt64(aR[i]))
		R.Add(R, gaL)
		R.Add(R, haR)
		i = i + 1
	}
	return R, nil
}

func CommitVectorBig(aL,aR []*big.Int, alpha *big.Int, G,H *bn256.G1, g,h []*bn256.G1, n int64) (*bn256.G1, error) {
	var (
		i int64
		R *bn256.G1
	)
	// Compute h^alpha.vg^aL.vh^aR
	R = new(bn256.G1).ScalarMult(H, alpha)
	i = 0
	for i<n {
		gaL := new(bn256.G1).ScalarMult(g[i], aL[i])
		haR := new(bn256.G1).ScalarMult(h[i], aR[i])
		R.Add(R, gaL)
		R.Add(R, haR)
		i = i + 1
	}
	return R, nil
}

/*
delta(y,z) = (z-z^2) . < 1^n, y^n > - z^3 . < 1^n, 2^n >
*/
func (zkrp *bp) Delta(y, z *big.Int) (*big.Int, error) {
	var (
		result *big.Int
	)
	// delta(y,z) = (z-z^2) . < 1^n, y^n > - z^3 . < 1^n, 2^n >
	z2 := Multiply(z, z)
	z2 = Mod(z2, bn256.Order) 
	z3 := Multiply(z2, z)
	z3 = Mod(z3, bn256.Order)

	// < 1^n, y^n >
	v1, _ := VectorCopy(new(big.Int).SetInt64(1), zkrp.n)
	vy, _ := PowerOf(y, zkrp.n) 
	sp1y, _ := ScalarProduct(v1, vy)

	// < 1^n, 2^n >
	p2n, _ := PowerOf(new(big.Int).SetInt64(2), zkrp.n)
	sp12, _ := ScalarProduct(v1, p2n)

	result = Sub(z, z2)
	result = Multiply(result, sp1y)
	result = Sub(result, Multiply(z3, sp12))
	result = Mod(result, bn256.Order)

	return result, nil
}

/* 
Setup is responsible for computing the common parameter. 
This is NOT a trusted setup.
*/
func (zkrp *bp) Setup(a,b int64) {
	var (
		i int64
	)
	zkrp.G = new(bn256.G1).ScalarBaseMult(new(big.Int).SetInt64(1))
	h := GetBigInt("18560948149108576432482904553159745978835170526553990798435819795989606410926")
	zkrp.H = new(bn256.G1).ScalarBaseMult(h)
	zkrp.n = int64(math.Log2(float64(b)))
	zkrp.g = make([]*bn256.G1, zkrp.n)
	zkrp.h = make([]*bn256.G1, zkrp.n)
	i = 0
	for i<zkrp.n {
		eg, _ := rand.Int(rand.Reader, bn256.Order)
		eh, _ := rand.Int(rand.Reader, bn256.Order)
		zkrp.g[i] = new(bn256.G1).ScalarBaseMult(eg)
		zkrp.h[i] = new(bn256.G1).ScalarMult(zkrp.H, eh)
		i = i + 1
	}
}

/* 
Prove computes the ZK proof. 
*/
func (zkrp *bp) Prove(secret *big.Int) (proofBP, error) {
	var (
		i int64
		sL []*big.Int
		sR []*big.Int
		proof proofBP
	)
	fmt.Println("############################# Prove #################################")
	//////////////////////////////////////////////////////////////////////////////
	// First phase
	//////////////////////////////////////////////////////////////////////////////
	
	// commitment to v and gamma
	gamma, _ := rand.Int(rand.Reader, bn256.Order)
	V, _ := CommitG1(secret, gamma, zkrp.H) 

	// aL, aR and commitment: (A, alpha)
	aL, _ := Decompose(secret, 2, zkrp.n)	
	aR, _ := ComputeAR(aL)
	fmt.Println("aL:")
	fmt.Println(aL)
	fmt.Println("aR:")
	fmt.Println(aR)
	alpha, _ := rand.Int(rand.Reader, bn256.Order)
	A, _ := CommitVector(aL, aR, alpha, zkrp.G, zkrp.H, zkrp.g, zkrp.h, zkrp.n) 

	// sL, sR and commitment: (S, rho)
	rho, _ := rand.Int(rand.Reader, bn256.Order)
	sL = make([]*big.Int, zkrp.n)
	sR = make([]*big.Int, zkrp.n)
	i = 0
	for i<zkrp.n {
		sL[i], _ = rand.Int(rand.Reader, bn256.Order)
		sR[i], _ = rand.Int(rand.Reader, bn256.Order)
		i = i + 1
	}
	S, _ := CommitVectorBig(sL, sR, rho, zkrp.G, zkrp.H, zkrp.g, zkrp.h, zkrp.n) 

	// Fiat-Shamir heuristic to compute challenges y, z
	y, z, _ := HashBP(A, S)

	//////////////////////////////////////////////////////////////////////////////
	// Second phase
	//////////////////////////////////////////////////////////////////////////////
	tau1, _ := rand.Int(rand.Reader, bn256.Order) // page 20 from eprint version
	tau2, _ := rand.Int(rand.Reader, bn256.Order)
	
	// compute t1: < aL - z.1^n, y^n . sR > + < sL, y^n . (aR + z . 1^n) > 
	vz, _ := VectorCopy(z, zkrp.n)
	vy, _ := PowerOf(y, zkrp.n) 

	// aL - z.1^n
	naL, _ := VectorConvertToBig(aL, zkrp.n)
	aLmvz, _ := VectorSub(naL, vz)
	
	// y^n .sR
	ynsR, _ := VectorMul(vy, sR) 	

	// scalar prod: < aL - z.1^n, y^n . sR >
	sp1, _ := ScalarProduct(aLmvz, ynsR)

	// scalar prod: < sL, y^n . (aR + z . 1^n) >
	naR, _ := VectorConvertToBig(aR, zkrp.n)
	aRzn, _ := VectorAdd(naR, vz)
	ynaRzn, _ := VectorMul(vy, aRzn) 

	// Add z^2.2^n to the result
	// z^2 . 2^n
	p2n, _ := PowerOf(new(big.Int).SetInt64(2), zkrp.n)
	zsquared := Multiply(z, z)
	z22n, _ := VectorScalarMul(p2n, zsquared)
	ynaRzn, _ = VectorAdd(ynaRzn, z22n)
	sp2, _ := ScalarProduct(sL, ynaRzn)
	
	// sp1 + sp2
	t1 := Add(sp1, sp2)
	t1 = Mod(t1, bn256.Order)
	

	// compute t2: < sL, y^n . sR >
	t2, _ := ScalarProduct(sL, ynsR)
	t2 = Mod(t2, bn256.Order)

	// compute T1
	T1, _ := CommitG1(t1, tau1, zkrp.H)

	// compute T2
	T2, _ := CommitG1(t2, tau2, zkrp.H)

	// Fiat-Shamir heuristic to compute 'random' challenge x
	x, _, _ := HashBP(T1, T2)

	//////////////////////////////////////////////////////////////////////////////
	// Third phase                                                              //
	//////////////////////////////////////////////////////////////////////////////

	// compute bl
	sLx, _ := VectorScalarMul(sL, x)
	bl, _ := VectorAdd(aLmvz, sLx)

	// compute br
	// y^n . ( aR + z.1^n + sR.x )
	sRx, _ := VectorScalarMul(sR, x)
	aRzn, _ = VectorAdd(aRzn, sRx)
	ynaRzn, _ = VectorMul(vy, aRzn) 
	// y^n . ( aR + z.1^n sR.x ) + z^2 . 2^n
	br, _ := VectorAdd(ynaRzn, z22n)

	// Compute t` = < bl, br >
	tprime, _ := ScalarProduct(bl, br)

	// Compute taux = tau2 . x^2 + tau1 . x + z^2 . gamma
	taux := Multiply(tau2, Multiply(x, x))
	taux = Add(taux, Multiply(tau1, x)) 
	taux = Add(taux, Multiply(Multiply(z, z), gamma))
	taux = Mod(taux, bn256.Order) 

	// Compute mu = alpha + rho.x
	mu := Multiply(rho, x)
	mu = Add(mu, alpha)
	mu = Mod(mu, bn256.Order) 

	// Remove unnecessary variables
	proof.V = V
	proof.A = A
	proof.S = S
	proof.T1 = T1
	proof.T2 = T2
	proof.taux = taux
 	proof.mu = mu
	proof.tprime = tprime
	proof.bl = bl
	proof.br = br

	return proof, nil
}

/* 
Verify returns true if and only if the proof is valid.
*/
func (zkrp *bp) Verify (proof proofBP) (bool, error) {
	var (
		i int64
		hprime []*bn256.G1
	)
	fmt.Println("############################# Verify #################################")
	hprime = make([]*bn256.G1, zkrp.n)
	y, z, _ := HashBP(proof.A, proof.S)
	x, _, _ := HashBP(proof.T1, proof.T2)

	// Switch generators
	yinv := ModInverse(y, bn256.Order)
	expy := yinv
	hprime[0] = zkrp.h[0]	
	i = 1
	for i<zkrp.n {
		hprime[i] = new(bn256.G1).ScalarMult(zkrp.h[i], expy)	
		expy = Multiply(expy, yinv)
		i = i + 1
	}

	//////////////////////////////////////////////////////////////////////////////
	// Check that tprime  = t(x) = t0 + t1x + t2x^2  ----------  Condition (65) //
	//////////////////////////////////////////////////////////////////////////////
	
	// Compute left hand side
	lhs, _ := CommitG1(proof.tprime, proof.taux, zkrp.H)
	
	// Compute right hand side
	z2 := Multiply(z, z)
	z2 = Mod(z2, bn256.Order) 
	x2 := Multiply(x, x)
	x2 = Mod(x2, bn256.Order) 

	rhs := new(bn256.G1).ScalarMult(proof.V, z2)

	delta, _ := zkrp.Delta(y,z)

	gdelta := new(bn256.G1).ScalarBaseMult(delta)

	rhs.Add(rhs, gdelta)

	T1x := new(bn256.G1).ScalarMult(proof.T1, x) 
	T2x2 := new(bn256.G1).ScalarMult(proof.T2, x2) 

	rhs.Add(rhs, T1x)
	rhs.Add(rhs, T2x2)

	// Subtract lhs and rhs and compare with poitn at infinity
	lhs = lhs.Neg(lhs)
	rhs.Add(rhs, lhs)
	c65 := rhs.IsZero() // Condition (65), page 20, from eprint version
	fmt.Println("########### Is infinity:")
	fmt.Println(c65)

	//////////////////////////////////////////////////////////////////////////////
	// Check that l,r are correct -------------------  Conditions (66) and (67) //
	//////////////////////////////////////////////////////////////////////////////

	// Compute P - lhs  #################### Condition (66) ######################

	// S^x
	Sx := new(bn256.G1).ScalarMult(proof.S, x)
	// A.S^x
	ASx := new(bn256.G1).Add(proof.A, Sx)

	// g^-z
	mz := Sub(bn256.Order, z)
	vmz, _ := VectorCopy(mz, zkrp.n)
	gpmz, _ := VectorExp(zkrp.g, vmz)

	// z.y^n
	vz, _ := VectorCopy(z, zkrp.n)
	vy, _ := PowerOf(y, zkrp.n) 
	zyn, _ := VectorMul(vy, vz) 

	p2n, _ := PowerOf(new(big.Int).SetInt64(2), zkrp.n)
	zsquared := Multiply(z, z)
	z22n, _ := VectorScalarMul(p2n, zsquared)

	// z.y^n + z^2.2^n
	zynz22n, _ := VectorAdd(zyn, z22n) 
	
	lP := new(bn256.G1)
	lP.Add(ASx, gpmz)
	
	// h'^(z.y^n + z^2.2^n)
	hprimeexp, _ := VectorExp(hprime, zynz22n)

	lP.Add(lP, hprimeexp)
	fmt.Println("lP:")
	fmt.Println(lP)

	// Compute P - rhs  #################### Condition (67) ######################

	// h^mu
	rP := new(bn256.G1).ScalarMult(zkrp.H, proof.mu)
	
	// g^l
	gpl, _:= VectorExp(zkrp.g, proof.bl)

	// hprime^r
	hprimepr, _:= VectorExp(hprime, proof.br)

	rP.Add(rP, gpl)
	rP.Add(rP, hprimepr)
	fmt.Println("rP:")
	fmt.Println(rP)

	// Subtract lhs and rhs and compare with poitn at infinity
	lP = lP.Neg(lP)
	rP.Add(rP, lP)
	c67 := rP.IsZero() // Condition (65), page 20, from eprint version
	fmt.Println("########### Is infinity:")
	fmt.Println(c67)

	//////////////////////////////////////////////////////////////////////////////
	// Check that l,r are correct -------------------  Conditions (66) and (67) //
	//////////////////////////////////////////////////////////////////////////////

	sp, _ := ScalarProduct(proof.bl, proof.br)
	fmt.Println(sp)
	fmt.Println(proof.tprime)
	c68 := sp.Cmp(proof.tprime) == 0
	fmt.Println("########## Scalar product valid:")
	fmt.Println(c68)
	
	//////////////////////////////////////////////////////////////////////////////
	// Check that (65) (67) (68) are TRUE                                       //
	//////////////////////////////////////////////////////////////////////////////
	
	result := c65 && c67 && c68
	fmt.Println("########## result:")
	fmt.Println(result)

	return result, nil
}

////////////////////////////// Inner Product //////////////////////////////

type bip struct {
	n int64
	c *big.Int
	u *bn256.G1
	H *bn256.G1
	g []*bn256.G1  
	h []*bn256.G1  
}

type proofBip struct {
	u *bn256.G1
	P *bn256.G1
	g *bn256.G1
	h *bn256.G1
	a *big.Int
	b *big.Int
}

/*
Hash is responsible for the computing a Zp element given elements from GT and G1.
*/
func HashIP(g,h []*bn256.G1, P *bn256.G1, c *big.Int, n int64) (*big.Int, error) {
	var (
		i int64
	)

	digest := sha256.New()
	digest.Write([]byte(P.String()))
	
	i = 0
	for i<n {
		digest.Write([]byte(g[i].String()))
		digest.Write([]byte(h[i].String()))
		i = i + 1
	}
	
	digest.Write([]byte(c.String()))
	output := digest.Sum(nil)
	tmp := output[0: len(output)]
	result, err := byteconversion.FromByteArray(tmp)
	
	return result, err
}

/*
CommitinnerProduct is responsible for calculating g^a.h^b.
*/
func CommitInnerProduct(g,h []*bn256.G1, a,b []*big.Int) (*bn256.G1, error) {
	var (
		result *bn256.G1
	)

	ga, _ := VectorExp(g, a)
	hb, _ := VectorExp(h, b)
	result = new(bn256.G1).Add(ga, hb)
	return result, nil
}

/*
SetupInnerProduct is responsible for computing the basic parameters that are common to both
Prove and Verify algorithms.
*/
func (zkip *bip) Setup(H *bn256.G1, g,h []*bn256.G1, c *big.Int) (bip, error) {
	var (
		params bip
	)
	
	zkip.g = make([]*bn256.G1, zkip.n)
	zkip.h = make([]*bn256.G1, zkip.n)
	ur := GetBigInt("18560948149108576432482904553159745978835170526553990798435819795989606410927")
	zkip.u = new(bn256.G1).ScalarBaseMult(ur)
	zkip.H = H
	zkip.g = g
	zkip.h = h
	zkip.c = c

	return params, nil
}


/*
InnerProductProve is responsible for the generation of the Inner Product Proof.
*/
func (zkip *bip) Prove(a,b []*big.Int, P *bn256.G1) (proofBip, error) {
	var (
		proof proofBip
		n,m int64
	)

	// Fiat-Shamir:
	// x = Hash(g,h,P,c)
	x, _ := HashIP(zkip.g, zkip.h, P, zkip.c, zkip.n)
	//x = new(big.Int).SetInt64(1)
	fmt.Println("Inner Product x:")
	fmt.Println(x)	
	fmt.Println("c:")
	fmt.Println(zkip.c)	
	fmt.Println("u:")
	fmt.Println(zkip.u)	
	// Pprime = P.u^(x.c)		
	ux := new(bn256.G1).ScalarMult(zkip.u, x)  
	uxc := new(bn256.G1).ScalarMult(ux, zkip.c)  
	P = new(bn256.G1).Add(P, uxc)
	fmt.Println("P.u^(x.c):")
	fmt.Println(P)	
	n = int64(len(a))
	m = int64(len(b))
	if (n != m) {
		return proof, errors.New("Size of first array argument must be equal to the second")
	} else {
		// Execute Protocol 2 recursively
		proof, err := BIP(a, b, zkip.g, zkip.h, ux, P, n)
		return proof, err
	}
		
	return proof, nil
}

/*
BIP is the main recursive function that will be used to compute the inner product argument.
*/
func BIP(a,b []*big.Int, g,h []*bn256.G1, u,P *bn256.G1, n int64) (proofBip, error) {
	var (
		proof proofBip
	)

	fmt.Println("u:")
	fmt.Println(u)
	if (n == 1) {
		// recursion end
		proof.a = a[0]
		proof.b = b[0]
		proof.g = g[0]
		proof.h = h[0]
		proof.P = P
		proof.u = u

	} else {
		// recursion

		// nprime := n / 2
		nprime := n / 2
		fmt.Println("nprime:")
		fmt.Println(nprime)

		// Compute cL = < a[:n'], b[n':] >
		cL, _ := ScalarProduct(a[:nprime], b[nprime:])
		fmt.Println("cL:")
		fmt.Println(cL)
		// Compute cR = < a[n':], b[:n'] >
		cR, _ := ScalarProduct(a[nprime:], b[:nprime])
		fmt.Println("cR:")
		fmt.Println(cR)
		// Compute L = g[n':]^(a[:n']).h[:n']^(b[n':]).u^cL
		L, _ := VectorExp(g[nprime:],a[:nprime])
		Lh, _ := VectorExp(h[:nprime], b[nprime:])
		L.Add(L, Lh)
		// TODO: uncomment next line
		L.Add(L, new(bn256.G1).ScalarMult(u, cL))
		fmt.Println("L:")
		fmt.Println(L)
		// Compute R = g[:n']^(a[n':]).h[n':]^(b[:n']).u^cR
		R, _ := VectorExp(g[:nprime],a[nprime:]) 
		Rh, _ := VectorExp(h[nprime:], b[:nprime])
		R.Add(R, Rh)
		// TODO: uncomment next line
		R.Add(R, new(bn256.G1).ScalarMult(u, cR))
		fmt.Println("R:")
		fmt.Println(R)

		// Fiat-Shamir:
		x, _, _ := HashBP(L, R)
		x = new(big.Int).SetInt64(1)
		fmt.Println("x:")
		fmt.Println(x)
		xinv := ModInverse(x, bn256.Order)

		// Compute g' = g[:n']^(x^-1) * g[n':]^(x)
		gprime, _ := VectorScalarExp(g[:nprime], xinv)
		gprime2, _ := VectorScalarExp(g[nprime:], x)
		gprime, _ = VectorECAdd(gprime, gprime2)
		fmt.Println("gprime:")
		fmt.Println(gprime)
		// Compute h' = h[:n']^(x)    * h[n':]^(x^-1)
		hprime, _ := VectorScalarExp(h[:nprime], x)
		hprime2, _ := VectorScalarExp(h[nprime:], xinv)
		hprime, _ = VectorECAdd(hprime, hprime2)
		fmt.Println("hprime:")
		fmt.Println(hprime)
		// Compute P' = L^(x^2).P.R^(x^-2)
		x2 := Multiply(x,x)
		x2 = Mod(x2, bn256.Order)
		x2inv := ModInverse(x2, bn256.Order)
		Pprime := new(bn256.G1).ScalarMult(L, x2)
		Pprime.Add(Pprime, P)
		Pprime.Add(Pprime, new(bn256.G1).ScalarMult(R, x2inv))
		fmt.Println("Pprime:")
		fmt.Println(Pprime)

		// Compute a' = a[:n'].x      + a[n':].x^(-1)
		aprime, _ := VectorScalarMul(a[:nprime], x)
		aprime2, _ := VectorScalarMul(a[nprime:], xinv)
		aprime, _ = VectorAdd(aprime, aprime2)
		fmt.Println("aprime:")
		fmt.Println(aprime)
		// Compute b' = b[:n'].x^(-1) + b[n':].x
		bprime, _ := VectorScalarMul(b[:nprime], xinv)
		bprime2, _ := VectorScalarMul(b[nprime:], x)
		bprime, _ = VectorAdd(bprime, bprime2)
		fmt.Println("bprime:")
		fmt.Println(bprime)

		fmt.Println("###############################################################")
		// recursion BIP(g',h',u,P'; a', b')
		proof, _ = BIP(aprime, bprime, gprime, hprime, u, Pprime, nprime)
	}
	return proof, nil
}

/* 
InnerProduct is responsible for the verification of the Inner Product Proof. 
*/
func (zkip *bip) Verify(proof proofBip) (bool, error) {
	
	// c == a*b
	fmt.Println("a:")
	fmt.Println(proof.a)
	fmt.Println("b:")
	fmt.Println(proof.b)
	ab := Multiply(proof.a, proof.b)
	ab = Mod(ab, bn256.Order)
	fmt.Println("ab:")
	fmt.Println(ab)
	fmt.Println("c:")
	fmt.Println(zkip.c)

	// P == g^a.h^b.u^c
	rhs := new(bn256.G1).ScalarMult(proof.g, proof.a)
	rhs.Add(rhs, new(bn256.G1).ScalarMult(proof.h, proof.b))
	rhs.Add(rhs, new(bn256.G1).ScalarMult(proof.u, ab))
	fmt.Println("P:")
	fmt.Println(proof.P)
	fmt.Println("rhs:")
	fmt.Println(rhs)

	nP := proof.P.Neg(proof.P)
	nP.Add(nP, rhs)
	c := nP.IsZero() 
	fmt.Println("########### Is infinity:")
	fmt.Println(c)
	
	return c, nil
}


























