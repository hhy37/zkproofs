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
	"fmt"
)

/*
Test method VectorCopy, which simply copies the first input argument to size n vector.
*/
func TestVectorCopy(t *testing.T) {
	var (
		result []*big.Int
	)
	result, _ = VectorCopy(new(big.Int).SetInt64(1), 3)
	fmt.Println(result)
}

/*
Test method VectorConvertToBig.
*/
func TestVectorConvertToBig(t *testing.T) {
	var (
		result []*big.Int
		a []int64
	)
	a = make([]int64, 3)
	a[0] = 3
	a[1] = 4
	a[2] = 5
	result, _ = VectorConvertToBig(a, 3)
	fmt.Println(result)
}

/*
Scalar Product returns the inner product between 2 vectors. 
*/
func TestScalarProduct(t *testing.T) {
	var (
		a,b []*big.Int
	)
	a = make([]*big.Int, 3)
	b = make([]*big.Int, 3)
	a[0] = new(big.Int).SetInt64(7)
	a[1] = new(big.Int).SetInt64(7)
	a[2] = new(big.Int).SetInt64(7)
	b[0] = new(big.Int).SetInt64(3)
	b[1] = new(big.Int).SetInt64(3)
	b[2] = new(big.Int).SetInt64(3)
	result, _ := ScalarProduct(a, b)
	fmt.Println("Scalar Product:")
	fmt.Println(result)
}

/*
Tests Vector addition.
*/
func TestVectorAdd(t *testing.T) {
	var (
		a,b []*big.Int
	)
	a = make([]*big.Int, 3)
	b = make([]*big.Int, 3)
	a[0] = new(big.Int).SetInt64(7)
	a[1] = new(big.Int).SetInt64(8)
	a[2] = new(big.Int).SetInt64(9)
	b[0] = new(big.Int).SetInt64(3)
	b[1] = new(big.Int).SetInt64(30)
	b[2] = new(big.Int).SetInt64(40)
	result, _ := VectorAdd(a, b)
	fmt.Println("Addition:")
	fmt.Println(result)
}

/*
Tests Vector subtraction.
*/
func TestVectorSub(t *testing.T) {
	var (
		a,b []*big.Int
	)
	a = make([]*big.Int, 3)
	b = make([]*big.Int, 3)
	a[0] = new(big.Int).SetInt64(7)
	a[1] = new(big.Int).SetInt64(8)
	a[2] = new(big.Int).SetInt64(9)
	b[0] = new(big.Int).SetInt64(3)
	b[1] = new(big.Int).SetInt64(30)
	b[2] = new(big.Int).SetInt64(40)
	result, _ := VectorSub(a, b)
	fmt.Println("Subtraction:")
	fmt.Println(result)
}

/*
Tests Vector componentwise multiplication.
*/
func TestVectorMul(t *testing.T) {
	var (
		a,b []*big.Int
	)
	a = make([]*big.Int, 3)
	b = make([]*big.Int, 3)
	a[0] = new(big.Int).SetInt64(7)
	a[1] = new(big.Int).SetInt64(8)
	a[2] = new(big.Int).SetInt64(9)
	b[0] = new(big.Int).SetInt64(3)
	b[1] = new(big.Int).SetInt64(30)
	b[2] = new(big.Int).SetInt64(40)
	result, _ := VectorMul(a, b)
	fmt.Println("Multiplication:")
	fmt.Println(result)
}

/*
Test method PowerOf, which must return a vector containing a growing sequence of
powers of 2.
*/
func TestPowerOf(t *testing.T) {
	result, _ := PowerOf(new(big.Int).SetInt64(3), 10)
	fmt.Println(result)
}

/*
Test teh ZK Range Proof scheme using Bulletproofs. 
*/
func TestBulletproofsZKRP(t *testing.T) {
	var (
		zkrp bp
	)
	zkrp.Setup(0,65536) // ITS BEING USED TO COMPUTE N 
	x := new(big.Int).SetInt64(123)
	proof, _ := zkrp.Prove(x)
	ok, _ := zkrp.Verify(proof)
	fmt.Println(ok)
}

/* 
Test Inner Product argument.
*/
func TestInnerProduct(t *testing.T) {
	var (
		zkrp bp
		zkip bip
		a []*big.Int
		b []*big.Int
	)
	// TODO:
	// Review if it is the best way, since we maybe could use the 
	// inner product independently of the range proof. 
	zkrp.Setup(0,4) 
	fmt.Println("n:")
	fmt.Println(zkrp.n)
	a = make([]*big.Int, zkrp.n)
	a[0] = new(big.Int).SetInt64(1)
	a[1] = new(big.Int).SetInt64(2)
	b = make([]*big.Int, zkrp.n)
	b[0] = new(big.Int).SetInt64(7)
	b[1] = new(big.Int).SetInt64(-1)
	c := new(big.Int).SetInt64(5)
	commit, _ := CommitInnerProduct(zkrp.g, zkrp.h, a, b)
	fmt.Println("commit:") 
	fmt.Println(commit)
	zkip.Setup(zkrp.H, zkrp.g, zkrp.h, c)
	proof, _ := zkip.Prove(a, b, commit)	
	ok, _ := zkip.Verify(proof)
	fmt.Println(ok)
}
