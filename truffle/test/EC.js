// @flow

const Elliptic = require('elliptic').ec;
const ec = new Elliptic('secp256k1');

const BigNumber = web3.BigNumber;
require('chai')
    .use(require('chai-as-promised'))
    .use(require('chai-bignumber')(web3.BigNumber))
    .should();

const EC = artifacts.require('EC');

var verbose = true;
function log (S) {
    if (verbose) {
        console.log(S);
    }
}

contract('EC', async function ([_, wallet1, wallet2, wallet3, wallet4, wallet5]) {
    const n = new BigNumber('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F', 16);
    const n2 = new BigNumber('FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141', 16);
    const gx = new BigNumber('79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798', 16);
    const gy = new BigNumber('483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8', 16);
    const gx2 = new BigNumber('c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee5', 16);
    const gy2 = new BigNumber('1ae168fea63dc339a3c58419466ceaeef7f632653266d0e1236431a950cfe52a', 16);
    const gx3 = new BigNumber('f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9', 16);
    const gy3 = new BigNumber('388f7b0f632de8140fe337e62a37f3566500a99934c2231b6cb9fd7584b8e672', 16);
    const gx4 = new BigNumber('e493dbf1c10d80f3581e4904930b1404cc6c13900ee0758474fa94abe8c4cd13', 16);
    const gy4 = new BigNumber('51ed993ea0d455b75642e2098ea51448d967ae33bfbdfe40cfe97bdc47739922', 16);
    const gxA = new BigNumber('6a04ab98d9e4774ad806e302dddeb63bea16b5cb5f223ee77478e861bb583eb3', 16);
    const gyA = new BigNumber('36b6fbcb60b5b3d4f1551ac45e5ffc4936466e7d98f6c7c0ec736539f74691a6', 16);
    const gxF = new BigNumber('9166c289b9f905e55f9e3df9f69d7f356b4a22095f894f4715714aa4b56606af', 16);
    const gyF = new BigNumber('f181eb966be4acb5cff9e16b66d809be94e214f06c93fd091099af98499255e7', 16);

    var ecCurve;

    before(async function () {
        ecCurve = await EC.new();
    });

    /*it('should Add two small numbers', async function () {
        const [x, z] = await ecCurve._jAdd.call(2, 3, 4, 5);
        x.should.be.bignumber.equal(22);
        z.should.be.bignumber.equal(15);
    });

    it('should Add one big numbers with one small', async function () {
        const [x, z] = await ecCurve._jAdd.call(n.sub(1), 1, 2, 1);
        x.should.be.bignumber.equal(1);
        z.should.be.bignumber.equal(1);
    });

    it('should Add two big numbers', async function () {
        const [x, z] = await ecCurve._jAdd.call(n.sub(1), 1, n.sub(2), 1);
        x.should.be.bignumber.equal(n.sub(3));
        z.should.be.bignumber.equal(1);
    });

    it('should Substract two small numbers', async function () {
        const [x, z] = await ecCurve._jSub.call(2, 3, 4, 5);
        x.should.be.bignumber.equal(n.sub(2));
        z.should.be.bignumber.equal(15);
    });

    it('should Substract one big numbers with one small', async function () {
        const [x, z] = await ecCurve._jSub.call(2, 1, n.sub(1), 1);
        x.should.be.bignumber.equal(3);
        z.should.be.bignumber.equal(1);
    });

    it('should Substract two big numbers', async function () {
        const [x, z] = await ecCurve._jSub.call(n.sub(2), 1, n.sub(1), 1);
        x.should.be.bignumber.equal(n.sub(1));
        z.should.be.bignumber.equal(1);
    });

    it('should Substract two same numbers', async function () {
        const [x, z] = await ecCurve._jSub.call(n.sub(16), 1, n.sub(16), 1);
        x.should.be.bignumber.equal(0);
        z.should.be.bignumber.equal(1);
    });

    it('should Multiply two small numbers', async function () {
        const [x, z] = await ecCurve._jMul.call(2, 3, 4, 5);
        x.should.be.bignumber.equal(8);
        z.should.be.bignumber.equal(15);
    });

    it('should Multiply one big numbers with one small', async function () {
        const [x, z] = await ecCurve._jMul.call(n.sub(1), 1, 2, 1);
        x.should.be.bignumber.equal(n.sub(2));
        z.should.be.bignumber.equal(1);
    });

    it('should Multiply two big numbers', async function () {
        const [x, z] = await ecCurve._jMul.call(n.sub(2), 1, n.sub(3), 1);
        x.should.be.bignumber.equal(6);
        z.should.be.bignumber.equal(1);
    });

    it('should Multiply one is zero', async function () {
        const [x, z] = await ecCurve._jMul.call(2, 3, 0, 5);
        x.should.be.bignumber.equal(0);
        z.should.be.bignumber.equal(15);
    });

    it('should Divide two small numbers', async function () {
        const [x, z] = await ecCurve._jDiv.call(2, 3, 4, 5);
        x.should.be.bignumber.equal(10);
        z.should.be.bignumber.equal(12);
    });

    it('should Divide one big numbers with one small', async function () {
        const [x, z] = await ecCurve._jDiv.call(n.sub(1), 1, 2, 1);
        x.should.be.bignumber.equal(n.sub(1));
        z.should.be.bignumber.equal(2);
    });

    it('should Divide two big numbers', async function () {
        const [x, z] = await ecCurve._jDiv.call(n.sub(2), 1, n.sub(3), 1);
        x.should.be.bignumber.equal(n.sub(2));
        z.should.be.bignumber.equal(n.sub(3));
    });

    it('should Divide one is zero', async function () {
        const [x, z] = await ecCurve._jDiv.call(2, 3, 0, 5);
        x.should.be.bignumber.equal(10);
        z.should.be.bignumber.equal(0);
    });

    it('should Calculate inverse', async function () {
        const d = 2;
        const inv = await ecCurve._inverse.call(d);
        const [x, z] = await ecCurve._jMul.call(d, 1, inv, 1);
        x.should.be.bignumber.equal(1);
        z.should.be.bignumber.equal(1);
    });

    it('Inverse of 0', async function () {
        const d = 0;
        const inv = await ecCurve._inverse.call(d);
        inv.should.be.bignumber.equal(0);
    });

    it('Inverse of 1', async function () {
        const d = 1;
        const inv = await ecCurve._inverse.call(d);
        inv.should.be.bignumber.equal(1);
    });

    it('should Calculate inverse -1', async function () {
        const d = n.sub(1);
        const inv = await ecCurve._inverse.call(d);
        const [x, z] = await ecCurve._jMul.call(d, 1, inv, 1);
        x.should.be.bignumber.equal(1);
        z.should.be.bignumber.equal(1);
    });

    it('should Calculate inverse -2', async function () {
        const d = n.sub(2);
        const inv = await ecCurve._inverse.call(d);
        const [x, z] = await ecCurve._jMul.call(d, 1, inv, 1);
        x.should.be.bignumber.equal(1);
        z.should.be.bignumber.equal(1);
    });

    it('should Calculate inverse big number', async function () {
        const d = '0xf167a208bea79bc52668c016aff174622837f780ab60f59dfed0a8e66bb7c2ad';
        const inv = await ecCurve._inverse.call(d);
        const [x, z] = await ecCurve._jMul.call(d, 1, inv, 1);
        x.should.be.bignumber.equal(1);
        z.should.be.bignumber.equal(1);
    });

    it('should double gx,gy', async function () {
        let ln = gx.mul(gx).mul(3);
        let ld = gy.mul(2);

        ln = ln.mod(n);
        ld = ld.mod(n);

        log('ln: ' + ln.toString(10));
        log('ld: ' + ld.toString(10));

        let x2ccN = ln.mul(ln);
        let x2ccD = ld.mul(ld);

        x2ccN = x2ccN.sub(gx.mul(2).mul(x2ccD));

        x2ccN = x2ccN.mod(n);
        if (x2ccN.lessThan(0)) x2ccN = x2ccN.add(n);
        x2ccD = x2ccD.mod(n);
        if (x2ccD.lessThan(0)) x2ccD = x2ccD.add(n);
        log('x2ccN: ' + x2ccN.toString(10));
        log('x2ccD: ' + x2ccD.toString(10));

        let y2ccN;
        y2ccN = gx.mul(x2ccD).mul(ln);
        y2ccN = y2ccN.sub(x2ccN.mul(ln));
        y2ccN = y2ccN.sub(gy.mul(x2ccD).mul(ld));

        let y2ccD;
        y2ccD = x2ccD.mul(ld);

        y2ccN = y2ccN.mod(n);
        if (y2ccN.lessThan(0)) y2ccN = y2ccN.add(n);
        y2ccD = y2ccD.mod(n);
        if (y2ccD.lessThan(0)) y2ccD = y2ccD.add(n);
        log('y2ccN: ' + y2ccN.toString(10));
        log('y2ccD: ' + y2ccD.toString(10));

        let ccD = y2ccD.mul(x2ccD);
        x2ccN = x2ccN.mul(y2ccD);
        y2ccN = y2ccN.mul(x2ccD);

        x2ccN = x2ccN.mod(n);
        if (x2ccN.lessThan(0)) x2ccN = x2ccN.add(n);
        y2ccN = y2ccN.mod(n);
        if (y2ccN.lessThan(0)) y2ccN = y2ccN.add(n);
        ccD = ccD.mod(n);
        if (ccD.lessThan(0)) ccD = ccD.add(n);
        log('x2ccN: ' + x2ccN.toString(10));
        log('y2ccN: ' + y2ccN.toString(10));
        log('y2ccD: ' + ccD.toString(10));

        let [x2, y2, z2] = await ecCurve._ecDouble.call(gx, gy, 1);
        log('x2: ' + x2.toString(10));
        log('y2: ' + y2.toString(10));
        log('z2: ' + z2.toString(10));

        const inv = await ecCurve._inverse.call(z2);
        log('Inverse: ' + inv.toString(10));
        log('Inv test: ' + inv.mul(z2).mod(n).toString(10));
        x2 = x2.mul(inv).mod(n);
        y2 = y2.mul(inv).mod(n);
        log('x2: ' + x2.toString(10));
        log('y2: ' + y2.toString(10));
        x2.should.be.bignumber.equal('89565891926547004231252920425935692360644145829622209833684329913297188986597');
        y2.should.be.bignumber.equal('12158399299693830322967808612713398636155367887041628176798871954788371653930');
    });

    it('Add EC', async function () {
        log('Start Add');
        var x2 = new BigNumber('89565891926547004231252920425935692360644145829622209833684329913297188986597');
        var y2 = new BigNumber('12158399299693830322967808612713398636155367887041628176798871954788371653930');
        let [x3, y3, z3] = await ecCurve._ecAdd.call(gx, gy, 1, x2, y2, 1);
        log('x3: ' + x3.toString(10));
        log('y3: ' + y3.toString(10));
        log('z3: ' + z3.toString(10));

        const inv = await ecCurve._inverse.call(z3);
        x3 = x3.mul(inv).mod(n);
        y3 = y3.mul(inv).mod(n);
        log('x3: ' + x3.toString(10));
        log('y3: ' + y3.toString(10));
        x3.should.be.bignumber.equal('112711660439710606056748659173929673102114977341539408544630613555209775888121');
        y3.should.be.bignumber.equal('25583027980570883691656905877401976406448868254816295069919888960541586679410');
    });

    it('2G+1G = 3G', async function () {
        this.timeout(120000);

        const [x2, y2, z2] = await ecCurve._ecDouble.call(gx, gy, 1);
        log('x2: ' + x2.toString(10));
        log('y2: ' + y2.toString(10));
        log('z2: ' + z2.toString(10));

        let [x3, y3, z3] = await ecCurve._ecAdd.call(gx, gy, 1, x2, y2, z2);
        log('x3: ' + x3.toString(10));
        log('y3: ' + y3.toString(10));
        log('z3: ' + z3.toString(10));

        let [x3c, y3c, z3c] = await ecCurve._ecMul.call(3, gx, gy, 1);
        log('x3c: ' + x3c.toString(10));
        log('y3c: ' + y3c.toString(10));
        log('z3c: ' + z3c.toString(10));

        const inv3 = await ecCurve._inverse.call(z3);
        x3 = x3.mul(inv3).mod(n);
        y3 = y3.mul(inv3).mod(n);
        log('Inv test: ' + inv3.mul(z3).mod(n).toString(10));
        log('x3n: ' + x3.toString(10));
        log('y3n: ' + y3.toString(10));

        const inv3c = await ecCurve._inverse.call(z3c);
        x3c = x3c.mul(inv3c).mod(n);
        y3c = y3c.mul(inv3c).mod(n);
        log('Inv test: ' + inv3c.mul(z3c).mod(n).toString(10));
        log('x3cn: ' + x3c.toString(10));
        log('y3cn: ' + y3c.toString(10));
        x3.should.be.bignumber.equal(x3c);
        y3.should.be.bignumber.equal(y3c);
    });

    it('should create a valid public key', async function () {
        this.timeout(120000);

        var key = ec.genKeyPair();
        var priv = key.getPrivate();
        var d = new BigNumber(priv.toString(16), 16);
        log(JSON.stringify(priv));
        var pub = key.getPublic();
        log(JSON.stringify(pub));
        var pub_x = new BigNumber(key.getPublic().x.toString(16), 16);
        var pub_y = new BigNumber(key.getPublic().y.toString(16), 16);
        log(d.toString(10));
        log(pub_x.toString(10));
        log(pub_y.toString(10));

        const [pub_x_calc, pub_y_calc] = await ecCurve.publicKey.call(d);
        pub_x_calc.should.be.bignumber.equal(pub_x);
        pub_y_calc.should.be.bignumber.equal(pub_y);
    });

    //
    //  Disabled due coverage increased gas
    //
    // it('should consume few gas', async function () {
    //     this.timeout(120000);

    //     const key = ec.genKeyPair();
    //     const d = new BigNumber(key.getPrivate().toString(16), 16);
    //     const gas = await ecCurve.publicKey.estimateGas(d);
    //     log('Estimate gas: ' + gas);
    //     gas.should.be.lessThan(1000000, 'Public key calculation gas should be lower that 1M');
    // });

    it('Key derived in both directions should be the same', async function () {
        this.timeout(120000);

        const key1 = ec.genKeyPair();
        const key2 = ec.genKeyPair();
        const d1 = new BigNumber(key1.getPrivate().toString(16), 16);
        const d2 = new BigNumber(key2.getPrivate().toString(16), 16);
        const pub1_x = new BigNumber(key1.getPublic().x.toString(16), 16);
        const pub1_y = new BigNumber(key1.getPublic().y.toString(16), 16);
        const pub2_x = new BigNumber(key2.getPublic().x.toString(16), 16);
        const pub2_y = new BigNumber(key2.getPublic().y.toString(16), 16);

        const [k1_2x, k1_2y] = await ecCurve.deriveKey.call(d1, pub2_x, pub2_y);
        log('k1_2x:' + k1_2x.toString(10));
        log('k1_2y:' + k1_2y.toString(10));

        const [k2_1x, k2_1y] = await ecCurve.deriveKey.call(d2, pub1_x, pub1_y);
        log('k2_1x:' + k2_1x.toString(10));
        log('k2_1y:' + k2_1y.toString(10));

        k2_1x.should.be.bignumber.equal(k1_2x);
        k2_1y.should.be.bignumber.equal(k1_2y);

        const kd = key1.derive(key2.getPublic()).toString(10);
        log('keyDerived: ' + kd);
        kd.should.be.bignumber.equal(k1_2x);
    });

    it('should follow associative property', async function () {
        this.timeout(120000);

        log('n: ' + n.toString(10));
        log('n2: ' + n2.toString(10));
        log('gx: ' + gx.toString(10));
        log('gy: ' + gy.toString(10));

        var key1 = ec.genKeyPair();
        var key2 = ec.genKeyPair();
        var d1 = new BigNumber(key1.getPrivate().toString(16), 16);
        var d2 = new BigNumber(key2.getPrivate().toString(16), 16);
        log('priv1:' + d1.toString(10));
        log('priv2:' + d2.toString(10));

        const [pub1_x, pub1_y] = await ecCurve.publicKey.call(d1);
        log('pub1_x:' + pub1_x.toString(10));
        log('pub1_y:' + pub1_y.toString(10));

        const [pub2_x, pub2_y] = await ecCurve.publicKey.call(d2);
        log('pub2_x:' + pub2_x.toString(10));
        log('pub2_y:' + pub2_y.toString(10));

        var d12 = (d1.add(d2)).mod(n2);
        log('priv12:' + d12.toString(10));
        const [pub12_x, pub12_y] = await ecCurve.publicKey.call(d12);
        log('pub12_x:' + pub12_x.toString(10));
        log('pub12_y:' + pub12_y.toString(10));

        let [add12_x, add12_y, add12_z] = await ecCurve._ecAdd.call(pub1_x, pub1_y, 1, pub2_x, pub2_y, 1);
        const inv = await ecCurve._inverse.call(add12_z);
        log('Inv test2: ' + inv.mul(add12_z).mod(n).toString(10));
        add12_x = add12_x.mul(inv).mod(n);
        add12_y = add12_y.mul(inv).mod(n);
        log('add12_x:' + add12_x.toString(10));
        log('add12_y:' + add12_y.toString(10));

        pub12_x.should.be.bignumber.equal(add12_x);
        pub12_y.should.be.bignumber.equal(add12_y);
    });

    it('should verify for private key 1', async function () {
        const q = await ecCurve.ecmul.call(gx, gy, 1);
        q[0].should.be.bignumber.equal(gx);
        q[1].should.be.bignumber.equal(gy);

        const pk = await ecCurve.publicKey.call(1);
        pk[0].should.be.bignumber.equal(gx);
        pk[1].should.be.bignumber.equal(gy);

        (await ecCurve.ecmulVerify.call(gx, gy, 1, gx, gy)).should.be.true;
        (await ecCurve.publicKeyVerify.call(1, gx, gy)).should.be.true;
    });

    it('should verify for private key 2', async function () {
        const q = await ecCurve.ecmul.call(gx, gy, 2);
        q[0].should.be.bignumber.equal(gx2);
        q[1].should.be.bignumber.equal(gy2);

        const pk = await ecCurve.publicKey.call(2);
        pk[0].should.be.bignumber.equal(gx2);
        pk[1].should.be.bignumber.equal(gy2);

        (await ecCurve.ecmulVerify.call(gx, gy, 2, gx2, gy2)).should.be.true;
        (await ecCurve.publicKeyVerify.call(2, gx2, gy2)).should.be.true;
    });

    it('should verify for private key 3', async function () {
        const q = await ecCurve.ecmul.call(gx, gy, 3);
        q[0].should.be.bignumber.equal(gx3);
        q[1].should.be.bignumber.equal(gy3);

        const pk = await ecCurve.publicKey.call(3);
        pk[0].should.be.bignumber.equal(gx3);
        pk[1].should.be.bignumber.equal(gy3);

        (await ecCurve.ecmulVerify.call(gx, gy, 3, gx3, gy3)).should.be.true;
        (await ecCurve.publicKeyVerify.call(3, gx3, gy3)).should.be.true;
    });

    it('should verify for private key 4', async function () {
        const q = await ecCurve.ecmul.call(gx, gy, 4);
        q[0].should.be.bignumber.equal(gx4);
        q[1].should.be.bignumber.equal(gy4);

        const pk = await ecCurve.publicKey.call(4);
        pk[0].should.be.bignumber.equal(gx4);
        pk[1].should.be.bignumber.equal(gy4);

        (await ecCurve.ecmulVerify.call(gx, gy, 4, gx4, gy4)).should.be.true;
        (await ecCurve.publicKeyVerify.call(4, gx4, gy4)).should.be.true;
    });

    it('should verify for private key 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', async function () {
        const q = await ecCurve.ecmul.call(gx, gy, '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
        q[0].should.be.bignumber.equal(gxA);
        q[1].should.be.bignumber.equal(gyA);

        const pk = await ecCurve.publicKey.call('0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
        pk[0].should.be.bignumber.equal(gxA);
        pk[1].should.be.bignumber.equal(gyA);

        (await ecCurve.ecmulVerify.call(gx, gy, '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', gxA, gyA)).should.be.true;
        (await ecCurve.publicKeyVerify.call('0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA', gxA, gyA)).should.be.true;
    });

    it('should verify for private key 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', async function () {
        const q = await ecCurve.ecmul.call(gx, gy, '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
        q[0].should.be.bignumber.equal(gxF);
        q[1].should.be.bignumber.equal(gyF);

        const pk = await ecCurve.publicKey.call('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF');
        pk[0].should.be.bignumber.equal(gxF);
        pk[1].should.be.bignumber.equal(gyF);

        (await ecCurve.ecmulVerify.call(gx, gy, '0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', gxF, gyF)).should.be.true;
        (await ecCurve.publicKeyVerify.call('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', gxF, gyF)).should.be.true;
    });

    //
    //  Disabled due coverage increased gas
    //
    // it('should consume few gas for verification', async function () {
    //     this.timeout(120000);

    //     const key = ec.genKeyPair();
    //     const d = new BigNumber(key.getPrivate().toString(16), 16);
    //     const gas = await ecCurve.publicKeyVerify.estimateGas('0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF', gxF, gyF);
    //     log('Estimate gas: ' + gas);
    //     gas.should.be.lessThan(35000, 'Public key verification gas should be lower that 35K');
    // });*/
});
