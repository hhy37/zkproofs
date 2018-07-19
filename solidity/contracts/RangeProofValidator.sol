pragma solidity ^0.4.18;

contract RangeProofValidator {

    int constant t = 128;
    int constant l = 40;

    // Convert bytes to array of big integers
    function validate(uint lower, uint upper, bytes commitment, bytes proof) view returns (bool) {
        bytes[] memory com = new bytes[](7);
        bytes[] memory prf = new bytes[](31);
        uint[] memory index;
        uint destPointer;
        uint srcPointer;

        assembly { index := commitment }
        for (uint i = 0; i < com.length; i++) {
            uint start = index[i];
            uint length = (i == com.length - 1 ? commitment.length : index[i+1]) - index[i];
            bytes memory part = new bytes(length);
            assembly {
                destPointer := add(part, 32)
                srcPointer := add(add(commitment, 32), start)
            }
            require(length < 2048);
            copyWords(destPointer, srcPointer, length);
            com[i] = part;
        }

        assembly { index := proof }

        for ( i = 0; i < prf.length; i++) {
            start = index[i];
            length = (i == prf.length - 1 ? proof.length : index[i+1]) - index[i];
            part = new bytes(length);
            assembly {
                destPointer := add(part, 32)
                srcPointer := add(add(proof, 32), start)
            }
            require(length < 8192);
            copyWords(destPointer, srcPointer, length);
            prf[i] = part;
        }

        return validateProof(lower, upper, com, prf);
    }

    function validateProof(uint lower, uint upper, bytes[] com, bytes[] prf) private view returns (bool) {
        // Stack too deep so store in memory: tmp = (a, b, cLeft, cRight)
        bytes[] memory tmp = new bytes[](11);

        int T = 2 * (t + l + 1) + int(bitLength(upper - lower));
        tmp[0] = toBigInt(lower);
        tmp[1] = toBigInt(upper);

        // Scale for Proof without Tolerance
        com[0] = modexp(com[0], shiftLeft(toBigInt(1), T), com[1]); // cPrime
        com[4] = modexp(com[4], shiftLeft(toBigInt(1), T), com[1]);
        tmp[0] = shiftLeft(tmp[0], T);
        tmp[1] = shiftLeft(tmp[1], T);
        tmp[4] = shiftLeft(toBigInt(upper - lower), T + 2);
        if (!validateFloorSqrt(prf[30], tmp[4])) {return false;} // for maxCommitment

        // Step 2
        // c / g^a = c * (1/g)^a
        tmp[2] = modmul(com[0], modexp(com[5], tmp[0], com[1]), com[1]);

        // g^b / c = g^b * (1/c)
        tmp[3] = modmul(modexp(com[2], tmp[1], com[1]), com[4], com[1]);

        // Return false if invalid inverse is provided
        if (!validateModInv(com[0], com[4], com[1])) {return false;}
        if (!validateModInv(com[2], com[5], com[1])) {return false;}
        if (!validateModInv(com[3], com[6], com[1])) {return false;}
        if (!validateModInv(prf[0], prf[18], com[1])) {return false;}
        if (!validateModInv(prf[1], prf[19], com[1])) {return false;}
        if (!validateModInv(prf[2], prf[20], com[1])) {return false;}
        if (!validateModInv(prf[7], prf[21], com[1])) {return false;}

        // Step 6
        tmp[2] = modmul(tmp[2], prf[18], com[1]);
        tmp[3] = modmul(tmp[3], prf[19], com[1]);

        // Return false if invalid inverse is provided
        if (!validateModInv(tmp[2], prf[22], com[1])) {return false;}
        if (!validateModInv(tmp[3], prf[23], com[1])) {return false;}

        // Get rid of negative exponents D1, D2
        tmp[5] = compare(prf[24], toBigInt(1)) == 0 ? com[6] : com[3];
        tmp[6] = compare(prf[25], toBigInt(1)) == 0 ? com[6] : com[3];
        tmp[7] = compare(prf[26], toBigInt(1)) == 0 ? com[6] : com[3];
        tmp[8] = compare(prf[27], toBigInt(1)) == 0 ? com[6] : com[3];
        tmp[9] = compare(prf[28], toBigInt(1)) == 0 ? com[6] : com[3];
        tmp[10] = compare(prf[29], toBigInt(1)) == 0 ? com[6] : com[3];

        // Step 7
        if (!validateSQ(com[1], com[2], tmp[5], tmp[6], prf[2], prf[3], prf[4], prf[5], prf[6], prf[18], prf[20])) {return false;}
        if (!validateSQ(com[1], com[2], tmp[7], tmp[8], prf[7], prf[8], prf[9], prf[10], prf[11], prf[19], prf[21])) {return false;}

        // Step 8
        if (!validateCFT(prf[30], com[1], com[2], tmp[9], prf[22], prf[12], prf[13], prf[14])) {return false;}
        if (!validateCFT(prf[30], com[1], com[2], tmp[10], prf[23], prf[15], prf[16], prf[17])) {return false;}

        return true;
    }

    function validateFloorSqrt(bytes memory sqrt, bytes memory N) view returns (bool) {
        bytes memory sqrtPlus = bigadd(sqrt, toBigInt(1));
        return compare(square(sqrt), N) <= 0 && compare(square(sqrtPlus), N) > 0;
    }

    function validateCFT(bytes memory b, bytes memory N, bytes memory g, bytes memory h, bytes memory Einv, bytes memory C,
        bytes memory D1, bytes memory D2) view returns (bool) {

        bytes memory c = bmod(C, shiftLeft(toBigInt(1), t));
        bytes memory W = trim(restoreCommitment(N, g, h, D1, D2, Einv, c));

        return compare(D1, multiply(c, b)) >= 0 &&
            compare(D1, shiftLeft(b, t + l)) <= 0 &&
            compare(loadHash(keccak256(W)), C) == 0;
    }

    function validateSQ(bytes memory N, bytes memory g, bytes memory h_orInv1, bytes memory h_orInv2, bytes memory F,
        bytes memory c, bytes memory D, bytes memory D1, bytes memory D2, bytes memory Einv, bytes memory Finv) view returns (bool) {

        return validateEC(N, g, F, h_orInv1, h_orInv2, Finv, Einv, c, D, D1, D2);
    }

    function validateEC(bytes memory N, bytes memory g1, bytes memory g2, bytes memory h1, bytes memory h2,
        bytes memory Einv, bytes memory Finv, bytes memory c, bytes memory D, bytes memory D1, bytes memory D2) view returns (bool) {

        bytes memory W1 = trim(restoreCommitment(N, g1, h1, D, D1, Einv, c));
        bytes memory W2 = trim(restoreCommitment(N, g2, h2, D, D2, Finv, c));

        return compare(loadHash(keccak256(W1, W2)), c) == 0;
    }

    function validateModInv(bytes memory a, bytes memory a_inv, bytes memory N) view returns (bool) {
        return compare(modmul(a, a_inv, N), toBigInt(1)) == 0;
    }

    function restoreCommitment(bytes memory N, bytes memory g, bytes memory h, bytes memory D1,
        bytes memory D2, bytes memory Einv, bytes memory c) view returns (bytes memory ret) {

        return modmul(modmul(modexp(g, D1, N), modexp(h, D2, N), N), modexp(Einv, c, N), N);
    }

    function loadHash(bytes32 f) view returns (bytes memory ret) {
        ret = new bytes(32);
        assembly {mstore(add(ret, 32), f) }
    }

    function bitLength(uint x) view returns (uint) {
        uint test = 1;
        for (uint i = 0; i < 256; i++) {
            if (x < test) return i;
            test = test * 2;
        }
        return 256;
    }

    function compare(bytes memory a, bytes memory b) view returns (int cmp) {
        (, cmp) = addOrSub(a, b, true);
    }

    function toBigInt(uint x) view returns (bytes memory ret) {
        ret = new bytes(32);
        assembly { mstore(add(ret, 32), x) }
    }

    function bignot(bytes memory x) view returns (bytes memory) {
        uint pointer;
        uint pointerEnd;
        assembly {
            pointer := add(x, 32)
            pointerEnd := add(pointer, mload(x))
        }
        for (; pointer < pointerEnd; pointer += 32) {
            assembly {
                mstore(pointer, not(mload(pointer)))
            }
        }
        return x;
    }

    function bigadd(bytes memory a, bytes memory b) view returns (bytes memory ret) {
        (ret, ) = addOrSub(a, b, false);
    }

    function bigsub(bytes memory a, bytes memory b) view returns (bytes memory ret) {
        (ret, ) = addOrSub(a, b, true);
    }

    function addOrSub(bytes memory _a, bytes memory _b, bool negative_b) view returns (bytes memory result, int cmp) {
        result = new bytes(_a.length > _b.length ? _a.length : _b.length);

        uint aStart;
        uint bStart;
        uint rStart;
        assembly {
            aStart := add(_a, 32)
            bStart := add(_b, 32)
            rStart := add(result, 32)
        }
        uint aPos = aStart + (_a.length - 32);
        uint bPos = bStart + (_b.length - 32);
        uint carry = 0;

        for(uint rPos = rStart + result.length - 32; rPos >= rStart; rPos -= 32) {
            uint aPart = 0;
            uint bPart = 0;
            if (aPos >= aStart) {
                assembly { aPart := mload(aPos) }
            }
            if (bPos >= bStart) {
                assembly { bPart := mload(bPos) }
            }
            if (negative_b) {
                assembly {
                    mstore(rPos, sub(sub(aPart, bPart), carry))
                }
                carry = (aPart - bPart > aPart || aPart - bPart - carry > aPart - bPart) ? 1 : 0;
            } else {
                assembly {
                    mstore(rPos, add(add(aPart, bPart), carry))
                }
                carry = (aPart + bPart < aPart || aPart + bPart + carry < aPart + bPart) ? 1 : 0;
            }
            if (aPart != bPart) cmp = 1;
            aPos -= 32;
            bPos -= 32;
        }

        // If overflow we have to add 1 in front
        if (carry == 1) {

            if (negative_b) return (bigadd(bignot(result), toBigInt(1)), -1);

            bytes memory result2 = new bytes(result.length + 32);
            assembly {
                aPos := add(result, 32)
                bPos := add(result2, 64)
            }
            copyWords(bPos, aPos, result.length);
            assembly {
                mstore(add(result2, 32), 1)
            }
            return (result2, 1);
        }
        return (result, cmp);
    }

    function square(bytes memory x) view returns (bytes memory ret) {
        bytes memory largeN = shiftLeft(x, int(x.length) * 8);
        return modexp(x, toBigInt(2), largeN);
    }

    // ab = ((a+b)^2-(a-b)^2) / 4
    function multiply(bytes memory a, bytes memory b) view returns (bytes memory ret) {
        bytes memory two = toBigInt(2);
        bytes memory sum = bigadd(a, b); // a+b
        bytes memory diff = bigsub(a, b); // abs(a-b)
        bytes memory largeN = shiftLeft(sum, int(sum.length) * 8);
        bytes memory sumSquared = modexp(sum, two, largeN); //(a+b)^2
        bytes memory diffSquared = modexp(diff, two, largeN); //(a-b)^2
        bytes memory ab4 = bigsub(sumSquared, diffSquared);
        ret = shiftLeft(ab4, -2);
    }

    function modmul(bytes memory a, bytes memory b, bytes memory N) view returns (bytes memory ret) {
        return bmod(multiply(a,b), N);
    }

    function copyWords(uint dest, uint src, uint len) private view {
        for(; len >= 32; len -= 32) {
            assembly {
                mstore(dest, mload(src))
            }
            dest += 32;
            src += 32;
        }
    }

    function trim(bytes memory x) view returns (bytes memory y) {
        require(x.length % 32 == 0);
        bool isZero = true;
        uint zeroCount;
        for (uint i = 0; i < x.length; i += 32) {
            assembly {
                isZero := iszero(mload(add(x, add(i, 32))))
            }
            if (isZero) {
                zeroCount += 32;
            } else {
                break;
            }
        }
        assembly {
            y := add(x, zeroCount)
            mstore(y, sub(mload(x), zeroCount))
        }
    }

    function shiftBitsRight(bytes x, uint bitShift) view returns (bytes memory y) {
        if (bitShift == 0) return x;
        require(bitShift <= 255);
        require(x.length % 32 == 0);

        y = new bytes(x.length);

        uint maskRight = (uint(1) << bitShift) - 1; // mask to get only the lower X bits
        uint multiplyRight = 2 ** (256 - bitShift);
        uint divideRemaining = 2 ** bitShift;
        for (uint i = 0; i < x.length; i += 32) {
            uint value;
            uint _dst;
            assembly {
                value := div(and(not(maskRight), mload(add(x, add(i, 32)))), divideRemaining)
            }
            if (i != 0) {
                // What moved from the previous word to this one
                assembly {
                    value := add(value, mul(and(maskRight, mload(add(x, i))), multiplyRight))
                }
            }
            assembly {
                _dst := add(y, add(i, 32))
                mstore(_dst, value)
            }
        }
    }

    function shiftLeft(bytes memory x, int n) view returns (bytes memory ret) {
        // New bitlength = x.length * 8 + n; round up to multiple of 256
        int newBitLength = ((255 + n + int(x.length * 8)) / 256) * 256;
        if (newBitLength <= 0) return new bytes(0);

        ret = new bytes(uint(newBitLength) / 8);
        uint copy_len = x.length < ret.length ? x.length : ret.length;
        uint _input;
        uint _output;
        assembly {
            _input := add(x, 32)
            _output := add(ret, 32)
        }

        copyWords(_output, _input, copy_len);

        // Apply bit shift (between 0 and 255 to the right)
        uint bitShift = uint(newBitLength - int(x.length * 8) - n);
        ret = trim(shiftBitsRight(ret, bitShift));
    }

    function bmod(bytes memory _x, bytes memory _mod) view returns (bytes memory ret) {
        return modexp(_x, toBigInt(1), _mod);
    }

    // Wrapper for built-in bigint_modexp, modified from https://gist.github.com/lionello/ee285ea220dc64517499c971ff92a2a5
    function modexp(bytes memory _base, bytes memory _exp, bytes memory _mod) view returns (bytes memory) {

        uint256 bl = _base.length;
        uint256 el = _exp.length;
        uint256 ml = _mod.length;
        bytes memory ret = new bytes(ml);
        uint inputSize = 96 + bl + el + ml;
        bytes memory rawInput = new bytes(inputSize);

        assembly {
            let freemem := add(rawInput, 32)
            mstore(freemem, bl)
            mstore(add(freemem,32), el)
            mstore(add(freemem,64), ml)

            let x := call(450, 0x4, 0, add(_base,32), bl, add(freemem,96), bl)
            x := call(450, 0x4, 0, add(_exp,32), el, add(freemem,add(96, bl)), el)
            x := call(450, 0x4, 0, add(_mod,32), ml, add(freemem,sub(inputSize, ml)), ml)

            x := call(sub(gas, 1350), 0x5, 0, freemem, inputSize, add(ret, 32), ml)
        }

        require(rawInput.length == 96 + bl + el + ml);
        return ret;
    }
}