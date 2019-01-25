pragma solidity ^0.4.24;

import "./EC.sol";
import "./Util.sol";
import "./Auxiliar.sol";
import "./Generators.sol";
import "./BPStructs.sol";

contract BP {

    event Log(address id, string s);

    EC ec;

    BPStructs.ipProof public zkproofIP;

    uint256[32] hhprimex;
    uint256[32] hhprimey;


    constructor() public {
        ec = new EC();
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

    function verifyIP() public constant returns (bool result) {

        uint256 i;
        uint256 nprime;
        uint256 nlast;
        uint256 ab;
        bool c;
        uint256 n;
        n = Generators.getn();
        BPStructs.DataIP memory dt;

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

        for (i = 0; i < 5; i++) {
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

    uint8 Vx = 0;
    uint8 Vy = 1;
    uint8 Ax = 2;
    uint8 Ay = 3;
    uint8 Sx = 4;
    uint8 Sy = 5;
    uint8 T1x = 6;
    uint8 T1y = 7;
    uint8 T2x = 8;
    uint8 T2y = 9;
    uint8 Tprime = 10;
    uint8 Taux = 11;
    uint8 Mu = 12;
    uint8 Commitx = 13;
    uint8 Commity = 14;

    function verifyBP(
        uint256[] args
    ) public constant returns (uint256 result) {

        uint256 i;
        bool ok;
        uint256 n = Generators.getn();
        BPStructs.Data memory dt;
        dt.Gx = Generators.getGx();
        dt.Gy = Generators.getGy();
        dt.Hx = Generators.getHx();
        dt.Hy = Generators.getHy();
        dt.Ggx = Generators.getGgx();
        dt.Ggy = Generators.getGgy();
        dt.Hhx = Generators.getHhx();
        dt.Hhy = Generators.getHhy();

        (dt.y, dt.z) = Util.hashBP(args[Ax], args[Ay], args[Sx], args[Sy]);
        (dt.x,) = Util.hashBP(args[T1x], args[T1y], args[T2x], args[T2y]);

        dt.yinv = ec._invF(dt.y);
        dt.expy = dt.yinv;
        dt.hprimex[0] = dt.Hhx[0];
        dt.hprimey[0] = dt.Hhy[0];
        for (i = 1; i < 32; i++) {
            (dt.hprimex[i], dt.hprimey[i]) = ec.ecmul(dt.Hhx[i], dt.Hhy[i], dt.expy);
            dt.expy = mulmod(dt.expy, dt.yinv, n);
        }

        // CommitG1
        (dt.lhsx, dt.lhsy) = Auxiliar.pedersen(args[Tprime], args[Taux]);

        dt.z2 = mulmod(dt.z, dt.z, n);
        dt.x2 = mulmod(dt.x, dt.x, n);

        (dt.rhsx, dt.rhsy) = ec.ecmul(args[Vx], args[Vy], dt.z2);
        (dt.delta) = Auxiliar.Delta(dt.y, dt.z);

        (dt.gdeltax, dt.gdeltay) = ec.ecmul(dt.Gx, dt.Gy, dt.delta);

        (dt.rhsx, dt.rhsy) = ec.ecadd(dt.rhsx, dt.rhsy, dt.gdeltax, dt.gdeltay);

        (dt.T1xx, dt.T1xy) = ec.ecmul(args[T1x], args[T1y], dt.x);
        (dt.T2x2x, dt.T2x2y) = ec.ecmul(args[T2x], args[T2y], dt.x2);

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

        (dt.Sxx, dt.Sxy) = ec.ecmul(args[Sx], args[Sy], dt.x);
        (dt.ASx, dt.ASy) = ec.ecadd(args[Ax], args[Ay], dt.Sxx, dt.Sxy);

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

        (dt.rPx, dt.rPy) = ec.ecmul(dt.Hx, dt.Hy, args[Mu]);
        (dt.rPx, dt.rPy) = ec.ecadd(dt.rPx, dt.rPy, args[Commitx], args[Commity]);

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

