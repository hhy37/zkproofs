
package zkrangeproof

import (
	"crypto/rand"
	"testing"

	"fmt"
	"math/big"

	"github.com/ing-bank/zkrangeproof/go-ethereum/crypto/secp256k1"
)

const TestCount = 1000

func TestScalarMult(t *testing.T) {
	curve := secp256k1.S256()
	a := make([]byte, 16)
	rand.Read(a)
	fmt.Println(a)
	A, _ := curve.ScalarBaseMult(a)
	fmt.Println("A:")
	fmt.Println(A)
}


func TestNeg(t *testing.T) {
	fmt.Println("Px, Py:")
	fmt.Println(GX, GY)
	a1 := new(big.Int).SetInt64(-1)
	A1 := new(p256).ScalarBaseMult(a1)
	fmt.Println("A1:")
	fmt.Println(A1)
	a2 := new(big.Int).SetInt64(2)
	A2 := new(p256).ScalarBaseMult(a2)
	fmt.Println("A2:")
	fmt.Println(A2)
	iA1 := new(p256).Neg(A1)	
	fmt.Println("iA1:")
	fmt.Println(iA1)
	iA2 := new(p256).Neg(A2)	
	fmt.Println("iA2:")
	fmt.Println(iA2)
	
	aA1iA1 := new(p256).Multiply(A1, iA1)
	fmt.Println("A1iA1:")
	fmt.Println(aA1iA1)

	aA2iA2 := new(p256).Multiply(A2, iA2)
	fmt.Println("A2iA2:")
	fmt.Println(aA2iA2)

	aA1A2 := new(p256).Multiply(A1, A2)
	fmt.Println("aA1A2:")
	fmt.Println(aA1A2)
	aA1A2iA1 := new(p256).Multiply(aA1A2, iA1)
	fmt.Println("aA1A2iA1:")
	fmt.Println(aA1A2iA1)
}

func TestIsZero(t *testing.T) {
	curve := secp256k1.S256()
	a := make([]byte, 32)
	//rand.Read(a)
	a = curve.N.Bytes()
	fmt.Println(a)
	Ax, Ay := curve.ScalarBaseMult(a)
	fmt.Println("Ax:")
	fmt.Println(Ax)
	fmt.Println("Ay:")
	fmt.Println(Ay)
	p1 := p256{X:Ax, Y:Ay}
	fmt.Println(p1)
	res := p1.IsZero()
	fmt.Println("res:")
	fmt.Println(res)
}

func TestAdd(t * testing.T) {
	curve := secp256k1.S256()
	a1 := new(big.Int).SetInt64(71).Bytes()
	A1x, A1y := curve.ScalarBaseMult(a1)
	p1 := &p256{X:A1x, Y:A1y}
	fmt.Println("p1:")
	fmt.Println(p1)
	a2 := new(big.Int).SetInt64(17).Bytes()
	A2x, A2y := curve.ScalarBaseMult(a2)
	p2 := &p256{X:A2x, Y:A2y}
	p3 := p1.Add(p1, p2)
	fmt.Println("p1:")
	fmt.Println(p1)
	fmt.Println("p3:")
	fmt.Println(p3)
	sa := new(big.Int).SetInt64(-88).Bytes()
	sAx, sAy := curve.ScalarBaseMult(sa)
	sp := &p256{X:sAx, Y:sAy}
	fmt.Println("sp:")
	fmt.Println(sp)
	p4 := p3.Add(p3, sp)
	fmt.Println("p4:")
	fmt.Println(p4)
}

func TestScalarMultp256(t *testing.T) {
	curve := secp256k1.S256()
	a1 := new(big.Int).SetInt64(71).Bytes()
	Ax, Ay := curve.ScalarBaseMult(a1)
	p1 := &p256{X:Ax, Y:Ay}
	fmt.Println("p1:")
	fmt.Println(p1)
	pr := p1.ScalarMult(p1, curve.N)
	fmt.Println("pr:")
	fmt.Println(pr)
}

func TestScalarBaseMult(t *testing.T) {
	a1 := new(big.Int).SetInt64(71)
	p1 := new(p256).ScalarBaseMult(a1)
	fmt.Println("p1:")
	fmt.Println(p1)
}

func TestMultiplyp256(t *testing.T) {
	a := new(big.Int).SetInt64(2)
	p := new(p256).ScalarBaseMult(a)
	//p := &p256{X:Ax, Y:Ay}
	fmt.Println("p:")
	fmt.Println(p)
	P1 := &p256{X:GX, Y:GY}
	P2 := &p256{X:GX, Y:GY}

	ddp := P1.Double(P1)
	fmt.Println("ddp:")
	fmt.Println(ddp)

	dp := P2.Multiply(P2, P2)
	fmt.Println("dp:")
	fmt.Println(dp)
	
}

func BenchmarkScalarMultp256(b *testing.B) {
	a := make([]byte, 32)
	b.ResetTimer()
	for i := 0; i < b.N; i++ {
		rand.Read(a)
		fmt.Println(a)
		A := new(p256).ScalarBaseMult(new(big.Int).SetBytes(a))
		fmt.Println("A:")
		fmt.Println(A)
	}
}
