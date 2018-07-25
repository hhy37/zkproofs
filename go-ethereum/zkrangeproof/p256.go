/*
Encapsulates secp256k1 elliptic curve.
*/ 

package zkrangeproof

import (
	"math/big"
	"github.com/ing-bank/zkrangeproof/go-ethereum/crypto/secp256k1"
)

var (	
	CURVE = secp256k1.S256()
	GX = CURVE.Gx
	GY = CURVE.Gy
)

type p256 struct {
	X, Y *big.Int
} 

func (p *p256) IsZero() bool {
	c1 := (p.X == nil || p.Y == nil)
	if !c1 {
		z := new(big.Int).SetInt64(0)
		return p.X.Cmp(z)==0 && p.Y.Cmp(z)==0
	}
	return true
}

func (p *p256) Neg(a *p256) (*p256) {
	// (X, Y) -> (x, X + Y) 
	if (a.IsZero()) {
		return p.SetInfinity()
	}
	one := new(big.Int).SetInt64(1)
	mone := new(big.Int).Sub(CURVE.N, one)
	p.ScalarMult(p, mone)
	return p
}

/*
Input points must be distinct
*/
func (p *p256) Add(a,b *p256) (*p256) {
	if (a.IsZero()) {
		p.X = b.X
		p.Y = b.Y
		return p 
	} else if (b.IsZero()) {
		p.X = b.X
		p.Y = b.Y
		return p 

	} 
	resx, resy := CURVE.Add(a.X, a.Y, b.X, b.Y)
	p.X = resx
	p.Y = resy
	return p 
}

func (p *p256) Double(a *p256) (*p256) {
	if (a.IsZero()) {
		return p.SetInfinity()
	}
	resx, resy := CURVE.Double(a.X, a.Y)
	p.X = resx
	p.Y = resy
	return p 
}

func (p *p256) ScalarMult(a *p256, n *big.Int) (*p256) {
	if (a.IsZero()) {
		return p.SetInfinity()
	}
	cmp := n.Cmp(big.NewInt(0))
	if cmp == 0 {
		return p.SetInfinity()
	} 
	n = Mod(n, CURVE.N)
	bn := n.Bytes()	
	resx, resy := CURVE.ScalarMult(a.X, a.Y, bn)
	p.X = resx
	p.Y = resy
	return p
}

func (p *p256) ScalarBaseMult(n *big.Int) (*p256) {
	cmp := n.Cmp(big.NewInt(0))
	if cmp == 0 {
		return p.SetInfinity()
	} 
	n = Mod(n, CURVE.N)
	bn := n.Bytes()	
	resx, resy := CURVE.ScalarBaseMult(bn)
	p.X = resx
	p.Y = resy
	return p
}

func (p *p256) Multiply(a,b *p256) (*p256) {
	if (a.IsZero()) {
		p.X = b.X
		p.Y = b.Y
		return p 
	} else if (b.IsZero()) {
		p.X = a.X
		p.Y = a.Y
		return p 
	} 
	if (a.X.Cmp(b.X)==0 && a.Y.Cmp(b.Y)==0) {
		resx, resy := CURVE.Double(a.X, a.Y)
		p.X = resx
		p.Y = resy
		return p
	}
	resx, resy := CURVE.Add(a.X, a.Y, b.X, b.Y)
	p.X = resx
	p.Y = resy
	return p
}

func (p *p256) SetInfinity() (*p256) {
	p.X = nil
	p.Y = nil
	return p
}

func (p *p256) String() string {
	return "p256(" + p.X.String() + "," + p.Y.String() + ")"
}
