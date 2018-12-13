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

package com.ing.blockchain.zk.ethereum;

import com.ing.blockchain.zk.demo.Config;
import org.web3j.crypto.Credentials;
import org.web3j.protocol.Web3j;
import org.web3j.protocol.Web3jService;
import org.web3j.protocol.http.HttpService;
import org.web3j.tx.TransactionManager;

import java.math.BigInteger;
import java.util.concurrent.TimeUnit;

public class EthereumClient {

    private final Web3j web3j;
    private static final BigInteger GAS_LIMIT = BigInteger.valueOf(99999999);
    private static final BigInteger GAS_PRICE = BigInteger.ONE;

    public EthereumClient(final String ethereumUrl) {
        web3j = Web3j.build(new HttpService(ethereumUrl));
    }

    public static EthereumClient getEthereumClient() {
        final String ethereumUrl = Config.getInstance().getProperty("ethereum.url");
        return new EthereumClient(ethereumUrl);
    }

    public boolean validate(BigInteger lowerBound, BigInteger upperBound, byte[] commitment, byte[] proof) {
        try {
            Credentials credentials = getCredentials();

            System.out.println("Deploying validator, sender = " + getAddress());
            RangeProofValidator rpv = RangeProofValidator.deploy(web3j, credentials, GAS_PRICE, GAS_LIMIT).sendAsync().get(40, TimeUnit.SECONDS);
            System.out.println("Deployed validator = " + rpv.getContractAddress());

            System.out.println("Calling validate(lowerBound, upperBound, commitment, proof) on validator contract.");

            boolean result = rpv.validate(lowerBound, upperBound, commitment, proof).send();

            if (result) {
                System.out.println("Proof validated successfully in Ethereum!");
                return true;
            } else {
                System.out.println("Proof validation failed in Ethereum");
                return false;
            }
        } catch (Exception e) {
            System.err.println("Cannot call smart contract: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Gets the private key for the Ethereum-account that interacts with the smart-contract.
     * For testing purpose it gets the private key from a config-file.
     * For production the private key should be retrieved from a wallet.
     * @return The credentials based on the private key.
     */
    private Credentials getCredentials() {
        final String privateKey = Config.getInstance().getProperty("private.key");
        return Credentials.create(privateKey);
    }

    public String getAddress() {
        return getCredentials().getAddress();
    }
}
