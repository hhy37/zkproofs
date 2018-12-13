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

import com.ing.blockchain.zk.TTPGenerator;
import com.ing.blockchain.zk.dto.Commitment;
import com.ing.blockchain.zk.dto.TTPMessage;
import com.ing.blockchain.zk.util.InputUtils;

import java.math.BigInteger;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

/**
 * Generates the commitment
 */
public class TTPDemo {

    public static void main(String[] args) {
        new TTPDemo().generateTrustedMessage();
    }

    public void generateTrustedMessage() {
        try (Scanner s = new Scanner(System.in)) {
            BigInteger x = InputUtils.readBigInteger(s, "Enter the secret value");

            TTPMessage message = TTPGenerator.generateTTPMessage(x);

            String fileName = Config.getInstance().getProperty("ttpmessage.file.name");
            InputUtils.saveObject(fileName, message);
        }
    }
}