pragma solidity ^0.4.24;

library BPStructs {

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

}
