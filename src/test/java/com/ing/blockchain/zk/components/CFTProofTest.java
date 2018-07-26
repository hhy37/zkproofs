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

package com.ing.blockchain.zk.components;

import com.ing.blockchain.zk.RangeProofTests;
import com.ing.blockchain.zk.TTPGenerator;
import com.ing.blockchain.zk.dto.CFTProof;
import com.ing.blockchain.zk.dto.SecretOrderGroup;
import com.ing.blockchain.zk.dto.SquareProof;
import org.junit.Test;

import java.math.BigInteger;
import java.security.SecureRandom;

public class CFTProofTest {

    SecretOrderGroup group = RangeProofTests.EXAMPLE_GROUP;
    BigInteger N = group.getN();
    BigInteger g = group.getG();
    BigInteger h = group.getH();

    @Test
    public void secretValueMaxInRange() {
        BigInteger x = new BigInteger("198741361684");
        BigInteger y = new BigInteger("65132818281239");
        BigInteger commitment = TTPGenerator.commit(group, x, y).getCommitmentValue();

        SecureRandom random = new SecureRandom();
        CFTProof proof = CFT.calculateProof(x, N, g, h, x, y, random);
        CFT.validateZeroKnowledgeProof(x, N, g, h, commitment, proof);
    }

    @Test(expected = IllegalArgumentException.class)
    public void secretValueAboveMax() {
        BigInteger x = new BigInteger("198741361684");
        BigInteger y = new BigInteger("65132818281239");
        BigInteger commitment = TTPGenerator.commit(group, x, y).getCommitmentValue();

        SecureRandom random = new SecureRandom();
        CFTProof proof = CFT.calculateProof(x.subtract(BigInteger.ONE), N, g, h, x, y, random);
        CFT.validateZeroKnowledgeProof(x.subtract(BigInteger.ONE), N, g, h, commitment, proof);
    }

    @Test
    public void secretValueBelowMax() {
        BigInteger x = new BigInteger("198741361684");
        BigInteger y = new BigInteger("65132818281239");
        BigInteger commitment = TTPGenerator.commit(group, x, y).getCommitmentValue();

        SecureRandom random = new SecureRandom();
        CFTProof proof = CFT.calculateProof(x.add(BigInteger.ONE), N, g, h, x, y, random);
        CFT.validateZeroKnowledgeProof(x.add(BigInteger.ONE), N, g, h, commitment, proof);
    }

    @Test
    public void secretValueNegative() {
        BigInteger x = new BigInteger("198741361684");
        BigInteger y = new BigInteger("65132818281239");
        BigInteger commitment = TTPGenerator.commit(group, x.negate(), y).getCommitmentValue();

        SecureRandom random = new SecureRandom();
        CFTProof proof = CFT.calculateProof(x, N, g, h, x.negate(), y, random);
        CFT.validateZeroKnowledgeProof(x, N, g, h, commitment, proof);
    }
}
