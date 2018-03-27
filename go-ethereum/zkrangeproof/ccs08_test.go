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

package zkrangeproof

import (
	"testing"
	"math/big"
	"crypto/rand"
	"fmt"
	"github.com/ing-bank/zkrangeproof/go-ethereum/crypto/bn256"
)

func TestDecompose(t *testing.T) {
	h := GetBigInt("925")
	decx, _ := Decompose(h, 10, 3)	
	if decx[0] != 5 || decx[1] != 2 || decx[2] != 9 {
		t.Errorf("Assert failure: expected true, actual: ", decx)
	}
}

func TestNegScalarBaseMulG1(t *testing.T) {
	b, _ := rand.Int(rand.Reader, bn256.Order)
	pb := new(bn256.G1).ScalarBaseMult(b)
	mb := Sub(new(big.Int).SetInt64(0), b)
	mpb := new(bn256.G1).ScalarBaseMult(mb)
	a := new(bn256.G1).Add(pb, mpb)
	aBytes := a.Marshal()
	fmt.Println(aBytes)
	for i := 0; i < len(aBytes); i++ {
		if aBytes[i] != 0 {
			t.Errorf("Assert failure: expected true, actual: ", aBytes[i] == 0)
		}
	}
}

func TestNegScalarBaseMulG2(t *testing.T) {
	b, _ := rand.Int(rand.Reader, bn256.Order)
	pb := new(bn256.G2).ScalarBaseMult(b)
	mb := Sub(new(big.Int).SetInt64(0), b)
	mpb := new(bn256.G2).ScalarBaseMult(mb)
	a := new(bn256.G2).Add(pb, mpb)
	if a.IsZero() != true {
		t.Errorf("Assert failure: expected true, actual: ", a.IsZero())
	}
}

func TestInvertGFp12(t *testing.T) {
	b, _ := rand.Int(rand.Reader, bn256.Order)
	c, _ := rand.Int(rand.Reader, bn256.Order)

	pb, _ := new(bn256.G1).Unmarshal(new(bn256.G1).ScalarBaseMult(b).Marshal())
	qc, _ := new(bn256.G2).Unmarshal(new(bn256.G2).ScalarBaseMult(c).Marshal())

	k1 := bn256.Pair(pb, qc)
	k2 := new(bn256.GT).Invert(k1)
	k3 := new(bn256.GT).Add(k1, k2)
	if k3.IsOne() != true {
		t.Errorf("Assert failure: expected true, actual: ", k3.IsOne())
	}
}

func TestZKRP_UL(t *testing.T) {
	var (
		r *big.Int
	)
	p, _ := SetupUL(10, 5)
	r, _ = rand.Int(rand.Reader, bn256.Order)
	proof_out, _ := ProveUL(new(big.Int).SetInt64(42176), r, p)
	result, _ := VerifyUL(&proof_out, &p, p.kp.pubk)
	fmt.Println("ZKRP UL result: ")
	fmt.Println(result)
	if result != true {
		t.Errorf("Assert failure: expected true, actual: ", result)
	}
}

func TestZKRP(t *testing.T) {
	var (
		r *big.Int
		result bool
	)
	fmt.Println("Setup")
	p, _ := Setup(1900, 2000)
	fmt.Println("Prove")
	r, _ = rand.Int(rand.Reader, bn256.Order)
	proof_out, e := Prove(new(big.Int).SetInt64(1983), r, *p)
	if e != nil {
		fmt.Println(e.Error())
	} 
	fmt.Println("Verify")
	result, _ = Verify(&proof_out, p, p.p.kp.pubk)
	fmt.Println("ZKRP result: ")
	fmt.Println(result)
	if result != true {
		t.Errorf("Assert failure: expected true, actual: ", result)
	}
}
