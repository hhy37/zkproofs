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
	"math/big"
	"errors"
	"crypto/sha256"
	"github.com/ing-bank/zkrangeproof/go-ethereum/byteconversion"
	"github.com/ing-bank/zkrangeproof/go-ethereum/crypto/bn256"
)

/* 
Decompose receives as input a bigint x and outputs an array of integers such that
x = sum(xi.u^i), i.e. it returns the decomposition of x into base u.
*/
func Decompose(x *big.Int, u int64, l int64) ([]int64, error) {
	var (
		result []int64
		i int64
	)
	result = make([]int64, l, l)
	i = 0
	for i<l {
		result[i] = Mod(x, new(big.Int).SetInt64(u)).Int64()
		x = new(big.Int).Div(x, new(big.Int).SetInt64(u))
		i = i + 1
	}
	return result, nil
}

func InvertBits(x []int64) ([]int64, error) {
	var (
		i int64
		result []int64
	)
	result = make([]int64, len(x))
	i = 0
	for i<int64(len(x)) {
		if x[i] == 0 {
			result[i] = 1 
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
CommitSet method corresponds to the Pedersen commitment scheme. Namely, given input 
message x, and randomness r, it outputs g^x.h^r.
*/
func CommitSet(x,r *big.Int, p paramsSet) (*bn256.G2, error) {
	var (
		C *bn256.G2
	)
	C = new(bn256.G2).ScalarBaseMult(x)
	C.Add(C, new(bn256.G2).ScalarMult(p.H, r))
	return C, nil
}

/*
Commit method corresponds to the Pedersen commitment scheme. Namely, given input 
message x, and randomness r, it outputs g^x.h^r.
*/
func Commit(x,r *big.Int, p paramsUL) (*bn256.G2, error) {
	var (
		C *bn256.G2
	)
	C = new(bn256.G2).ScalarBaseMult(x)
	C.Add(C, new(bn256.G2).ScalarMult(p.H, r))
	return C, nil
}

/*
HashSet is responsible for the computing a Zp element given elements from GT and G2.
*/
func HashSet(a *bn256.GT, D *bn256.G2) (*big.Int, error) {
	digest := sha256.New()
	digest.Write([]byte(a.String()))
	digest.Write([]byte(D.String()))
	output := digest.Sum(nil)
	tmp := output[0: len(output)]
	return byteconversion.FromByteArray(tmp)
}

/*
Hash is responsible for the computing a Zp element given elements from GT and G2.
*/
func Hash(a []*bn256.GT, D *bn256.G2) (*big.Int, error) {
	digest := sha256.New()
	for i := range a {
		digest.Write([]byte(a[i].String()))
	}
	digest.Write([]byte(D.String()))
	output := digest.Sum(nil)
	tmp := output[0: len(output)]
	return byteconversion.FromByteArray(tmp)
}

/*
Read big integer in base 10 from string.
*/
func GetBigInt(value string) *big.Int {
	i := new(big.Int)
	i.SetString(value, 10)
	return i
}

