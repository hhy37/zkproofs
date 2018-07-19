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

package com.ing.blockchain.zk.demo;

import com.ing.blockchain.zk.RangeProof;
import com.ing.blockchain.zk.dto.*;
import com.ing.blockchain.zk.ethereum.EthereumClient;
import com.ing.blockchain.zk.util.ExportUtil;
import com.ing.blockchain.zk.util.InputUtils;

import javax.xml.bind.DatatypeConverter;
import java.util.Scanner;

public class ProverDemo {

    public static void main(String args[]) {

        new ProverDemo().runValidation(true);
    }

    public void runValidation(final boolean runOnEthereum) {

        ClosedRange range = InputUtils.readRange(new Scanner(System.in));

        System.out.println("Reading commitment from trusted 3rd party");

        String fileName = Config.getInstance().getProperty("ttpmessage.file.name");
        TTPMessage ttpMessage = (TTPMessage) InputUtils.readObject(fileName);
        Commitment commitment = ttpMessage.getCommitment();

        if (!range.contains(ttpMessage.getX())) {
            throw new IllegalArgumentException("Provided range does not contain the committed value");
        }

        BoudotRangeProof rangeProof = RangeProof.calculateRangeProof(ttpMessage, range);
        //InputUtils.saveObject("src/main/resources/range-proof.data", rangeProof);
        //BoudotRangeProof rangeProof = (BoudotRangeProof)InputUtils.readObject("src/main/resources/range-proof.data");

        System.out.println("Commitment = ");
        System.out.println(DatatypeConverter.printHexBinary(ExportUtil.exportForEVM(commitment)));

        System.out.println("Proof = ");
        System.out.println(DatatypeConverter.printHexBinary(ExportUtil.exportForEVM(rangeProof, commitment, range)));

        validateJava(rangeProof, commitment, range);
        if (runOnEthereum) {
            validateEVM(rangeProof, commitment, range);
        }
    }

    void validateJava(BoudotRangeProof rangeProof, Commitment commitment, ClosedRange range) {

        try {
            RangeProof.validateRangeProof(rangeProof, commitment, range);
            System.out.println("Range proof validated successfully");
        } catch (Exception e) {
            System.err.println("Range proof validation error: " + e.getMessage());
            throw e;
        }
    }

    void validateEVM(BoudotRangeProof rangeProof, Commitment commitment, ClosedRange range) {

        EthereumClient client = EthereumClient.getEthereumClient();

        if (!client.validate(range.getStart(), range.getEnd(),
                ExportUtil.exportForEVM(commitment), ExportUtil.exportForEVM(rangeProof, commitment, range))) {
            System.err.println("Range proof validation failed");
        }

    }
}