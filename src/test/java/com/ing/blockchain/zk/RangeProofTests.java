/*
 * Copyright 2017 ING Bank N.V.
 * This file is part of the go-ethereum library.
 *
 * The go-ethereum library is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The go-ethereum library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with the go-ethereum library. If not, see <http://www.gnu.org/licenses/>.
 *
 */

package com.ing.blockchain.zk;

import com.ing.blockchain.zk.dto.*;
import com.ing.blockchain.zk.exception.ZeroKnowledgeException;
import org.junit.Test;

import java.math.BigInteger;

import static junit.framework.TestCase.fail;

public class RangeProofTests {

    public static final SecretOrderGroup EXAMPLE_GROUP = new SecretOrderGroup(
            new BigInteger("123763483659823661164839153854113"),
            new BigInteger("9978076495933337078596144096749"),
            new BigInteger("46959937887401751832025265468109"));

    private BigInteger[] toArray(BoudotRangeProof p) {
        BigInteger[] res = new BigInteger[18];
        res[0] = p.getCLeftSquare();
        res[1] = p.getCRightSquare();
        res[2] = p.getSqrProofLeft().getF();
        res[3] = p.getSqrProofLeft().getECProof().getC();
        res[4] = p.getSqrProofLeft().getECProof().getD();
        res[5] = p.getSqrProofLeft().getECProof().getD1();
        res[6] = p.getSqrProofLeft().getECProof().getD2();
        res[7] = p.getSqrProofRight().getF();
        res[8] = p.getSqrProofRight().getECProof().getC();
        res[9] = p.getSqrProofRight().getECProof().getD();
        res[10] = p.getSqrProofRight().getECProof().getD1();
        res[11] = p.getSqrProofRight().getECProof().getD2();
        res[12] = p.getCftProofLeft().getC();
        res[13] = p.getCftProofLeft().getD1();
        res[14] = p.getCftProofLeft().getD2();
        res[15] = p.getCftProofRight().getC();
        res[16] = p.getCftProofRight().getD1();
        res[17] = p.getCftProofRight().getD2();
        return res;
    }

    private BoudotRangeProof fromArray(BigInteger[] proof) {
        ECProof ecProof1 = new ECProof(proof[9], proof[10], proof[11], proof[12]);
        ECProof ecProof2 = new ECProof(proof[14], proof[15], proof[16], proof[17]);
        SquareProof sqrProof1 = new SquareProof(proof[8], ecProof1);
        SquareProof sqrProof2 = new SquareProof(proof[13], ecProof2);
        CFTProof cftProof1 = new CFTProof(proof[2], proof[3], proof[4]);
        CFTProof cftProof2 = new CFTProof(proof[5], proof[6], proof[7]);
        return new BoudotRangeProof(proof[0], proof[1], sqrProof1, sqrProof2, cftProof1, cftProof2);
    }

    private void checkProofRejection(BigInteger[] fakeProofArray, Commitment c, ClosedRange range) {
        BoudotRangeProof fakeProof = fromArray(fakeProofArray);
        try {
            RangeProof.validateRangeProof(fakeProof, c, range);
            fail("No error at fake proof");
        } catch (ZeroKnowledgeException e) {
            System.out.println("Fake proof was rejected");
        }
    }

    @Test
    public void testValidRangeProof() throws Exception {
        BigInteger x = new BigInteger("50");

        TTPMessage message = TTPGenerator.generateTTPMessage(x, EXAMPLE_GROUP);
        ClosedRange range = ClosedRange.of("10", "100");

        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);

        RangeProof.validateRangeProof(rangeProof, message.getCommitment(), range);

        System.out.println("C = " + message.getCommitment().getCommitmentValue());
        BigInteger[] bigIntegers = toArray(rangeProof);
        for (int i = 0; i < bigIntegers.length; i++) {
            System.out.println(bigIntegers[i]);
        }
    }


    @Test
    public void testAllFieldsCheckedForRangeProof() throws Exception {
        BigInteger x = new BigInteger("50");

        TTPMessage message = TTPGenerator.generateTTPMessage(x, EXAMPLE_GROUP);
        ClosedRange range = ClosedRange.of("10", "100");
        BigInteger[] proof = toArray(RangeProof.calculateRangeProof(message, range));

        for (int i = 0; i < proof.length; i++) {
            System.out.println("Modifying field " + i);
            BigInteger realValue = proof[i];
            proof[i] = BigInteger.ONE;
            checkProofRejection(proof, message.getCommitment(), range);
            proof[i] = BigInteger.ZERO;
            checkProofRejection(proof, message.getCommitment(), range);
            proof[i] = message.getCommitment().getCommitmentValue();
            checkProofRejection(proof, message.getCommitment(), range);
            proof[i] = realValue;
        }
    }

    @Test (expected = ZeroKnowledgeException.class)
    public void testInvalidRange() throws Exception {
        BigInteger x = new BigInteger("50");

        TTPMessage message = TTPGenerator.generateTTPMessage(x, EXAMPLE_GROUP);
        ClosedRange range = ClosedRange.of("10", "100");
        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);

        ClosedRange fakeRange = ClosedRange.of("51", "100");
        RangeProof.validateRangeProof(rangeProof, message.getCommitment(), fakeRange);
    }

    @Test (expected = ZeroKnowledgeException.class)
    public void testMismatchValidRange() throws Exception {
        BigInteger x = new BigInteger("100");

        TTPMessage message = TTPGenerator.generateTTPMessage(x, EXAMPLE_GROUP);
        ClosedRange range = ClosedRange.of("10", "100");
        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);

        ClosedRange fakeRange = ClosedRange.of("11", "100");
        RangeProof.validateRangeProof(rangeProof, message.getCommitment(), fakeRange);
    }

    @Test (expected = IllegalArgumentException.class)
    public void testRangeTooHigh() throws Exception {
        BigInteger x = new BigInteger("50");
        TTPMessage message = TTPGenerator.generateTTPMessage(x, EXAMPLE_GROUP);
        ClosedRange range = ClosedRange.of("51", "100");
        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);
    }

    @Test (expected = IllegalArgumentException.class)
    public void testRangeTooLow() throws Exception {
        BigInteger x = new BigInteger("50");
        TTPMessage message = TTPGenerator.generateTTPMessage(x, EXAMPLE_GROUP);
        ClosedRange range = ClosedRange.of("10", "49");
        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);
    }

    @Test
    public void testLargeValueLargeRange() throws Exception {
        BigInteger largeValue = BigInteger.valueOf(2).pow(200);
        TTPMessage message = TTPGenerator.generateTTPMessage(largeValue, EXAMPLE_GROUP);

        // Large range
        ClosedRange range = ClosedRange.of(largeValue.shiftRight(10), largeValue.shiftLeft(10));
        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);
        RangeProof.validateRangeProof(rangeProof, message.getCommitment(), range);
    }

    @Test
    public void testLargeValueSmallRange() throws Exception {
        BigInteger largeValue = BigInteger.valueOf(2).pow(128);
        TTPMessage message = TTPGenerator.generateTTPMessage(largeValue, EXAMPLE_GROUP);

        // Small range
        ClosedRange range = ClosedRange.of(largeValue, largeValue);
        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(message, range);
        RangeProof.validateRangeProof(rangeProof, message.getCommitment(), range);
    }
}