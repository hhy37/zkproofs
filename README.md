## Zero Knowledge Range Proof

ING's zero knowledge range-proof precompiled contract for the go-ethereum client.

## Important note:

The current version of this library implements the whitepaper “An Efficient Range Proof Scheme” by Kun Peng and Feng Bao. As discovered by Madars Virza, Research Scientist MIT Media Lab, this protocol contains a potential security vulnerability.

*“The publicly computable value y/t is roughly the same magnitude (in expectation) as w^2 \* (m-a+1)(b-m+1). However, w^2 has fixed bit length (again, in expectation) and thus for a fixed range, this value leaks the magnitude of the committed value.”*

Therefore, the proof is not zero knowledge. We’re currently evaluating which protocol to use instead in order to provide a secure Zero Knowledge Proof protocol.

## Intro

One fundamental concern in blockchain technology is the confidentiality of the data on the blockchain. In order to reach consensus between all independent nodes in a blockchain network, each node must be able to validate all transactions (for instance against double-spent), in most cases this means that the content of the transactions is visible to all nodes. Fortunately several solutions exist that preserve confidentiality on a blockchain (private transactions, HyperLedger Fabric Channels, Payment Channels, Homomorphic encryption, transaction-mixing, zero knowledge proofs etc.). This article describes the implementation of a zero-knowledge range-proof in Ethereum.

The zero knowledge range proof allows the blockchain network to validate that a secret number is within known limits without disclosing the secret number. This is useful to reach consensus in a variety of use cases:

 * Validate that someone's age is between 18 and 65 without disclosing the age.
 * Validate that someone is in Europe without disclosing the exact location.
 * Validate that a payment-amount is positive without disclosing the amount (as done by Monero).

The zero-knowledge range-proof requires a commitment on a number by a trusted party (for instance a government committing on someone's age), an Ethereum-user can use this commitment to generate a range-proof. The Ethereum network will verify this proof.


## Fiat–Shamir

Though the original 'Efficient range-proof' by Kun Peng required interaction between the prover and the validator, we adjusted the protocol to become non-interactive so that it would become usable on a blockchain (where each node needs to be able to verify autonomously without interaction with the client). We made the protocol non-interactive using the Fiat–Shamir heuristic.

## Precompiled contract

The range proof consists of 2 parts:
 * Generating the proof that a number is within an interval (outside the blockchain by the client that submits that proof)
 * Validating the proof that this number is within that interval (executed by each validating node on the blockchain)

On Ethereum validation of transactions in smart contract logic is typically done in the Ethereum Virtual Machine. However the operations involved in the validation of this range-proof are too computationally expensive to run on the EVM. Therefore we validate the range proof in a precompiled contract. We added this precompiled contract to the Ethereum Go Client (Geth).  A precompiled contract is written in the native language of the Ethereum-client (in our case in Golang) and is preconfigured to live at a specific address (with a low number). The precompiled contract can be called from Solidity in 2 ways:

 * By referring to the address with a Solidity interface (works until Solidity 0.3.6. and requires the address to have a balance of at least one wei (preconfigured in the genesis block)).
 * By extending the Solidity language to include additional functions in which case the Solidity code will be compiled to call the precompiled smart contract at the same preconfigured address.

 ## Gas consumption

 Ethereum uses the concept of gas which means the sender of a transaction needs to pay (i.e. Eth or Etc) for the computational steps executed by the smart-contract that is invoked by the transaction. The more complex computations the smart contract executes, the more gas will be consumed. Therefore the transaction specifies a gas limit and a gas price.

 Gas limit is there to protect you from buggy code running until your funds are depleted. The product of gasPrice and gas represents the maximum amount of Wei that you are willing to pay for executing the transaction. What you specify as gasPrice is used by miners to rank transactions for inclusion in the blockchain. It is the price in Wei of one unit of gas, in which VM operations are priced.



 Determining the right gas-consumption is crucial for correct functioning of Ethereum. Too low gas introduces a DOS vulnerability, attackers can make the network slow by calling computationally hard functions while paying relatively little. Too high gas wastes people’s money.


 We benchmarked the zkRangeProof verification against various other built-in Ethereum functions which resulted in a gas-consumption of 180,000.


## Usage

The usage of this go-ethereum library consists of four parts:
1. Running a modified ethereum Geth client that contains the precompiled smart contract;
2. Generating a commitment (in Java);
3. Generating a range proof (in Java);
4. Validating range proofs with the precompiled smart contract (in Java, uPort, or via console).

We will describe each step in more detail below. We have tried to make these instructions accessible for a broad audience.

#### Setting up the modified Geth client

Make sure that you have `make`, `golang-go`, and `gradle` installed. For `gradle`, this ppa can be used: `ppa:cwchien/gradle`.

Clone this repository, navigate to the go-ethereum folder and run:
```
$ make geth
```

You can now use the modified Geth client. From the zkrangeproof folder, use
```
$ ./go-ethereum/build/bin/geth
```

#### Generating commitments

Open a project in your favourite IDE and make sure that you have an IDE (plugin) that supports Gradle, or another dependency manager.
Note that this is a go-ethereum library; you cannot 'run' anything directly.

You can now i.e. add a new java package to the project.
The input for the commitment is a 'secret' `BigInteger` (`java.math.BigInteger`) and a `SecretOrderGroup`. You can generate the `SecretOrderGroup` with:
```java
// import com.ing.blockchain.zk.SecretOrderGroupGenerator
// import com.ing.blockchain.zk.dto.SecretOrderGroup
new SecretOrderGroupGenerator(512).generate();
```
where `512` is the bitlength (higher is safer, but also reduces the efficiency).

You can now generate the TTPMessage, which contains the commitment, using:
```java
// import com.ing.blockchain.zk.TTPGenerator
// import com.ing.blockchain.zk.dto.TTPMessage
TTPMessage ttpMessage = TTPGenerator.generateTTPMessage(x, group);
```
where `x` is the 'secret' `BigInteger` and `group` the `SecretOrderGroup`.

This TTPMessage contains six attributes: the first four together describe the commitment, whereas the latter two are private variables for the user that are also needed to generate range proofs.
The commitment can be retrieved with the `getCommitment()` method, and the private variables can be retrieved with the `getX()` and `getY()` methods.
The four different segments of the commitment can then be retrieved by calling the methods `getCommitmentValue()`, `getGroup().getN()`, `getGroup().getG()`, and `getGroup().getH()` on the result of `getCommitment()`.

In the precompiled smart contract we expect the commitment to be (only) the first four variables of the TTPMessage, separated by commas.

#### Generating range proofs

Given the commitment and the user's private variables, we can generate proofs for specific ranges. Hence, we need the TTPMessage here.
Other inputs are a lower bound and an upper bound for the range proof. The bounds need to match with the bounds that are being checked by the relying party.
The range must be supplied as a `ClosedRange`:
```java
// import com.ing.blockchain.zk.dto.*
ClosedRange range = new ClosedRange.of(lower, upper);
```
where `lower` and `upper` are BigIntegers.

A range proof should only be generated if this range contains the secret value:
```java
if (range.contains(ttpMessage.getX()))
```

The range proof can now be generated by calling:
```java
// import com.ing.blockchain.zk.HPAKErangeProof
RangeProof rangeProof = HPAKErangeProof.calculateRangeProof(ttpMessage, range);
```

And can directly be verified by:
```java
HPAKErangeProof.validateRangeProof(rangeProof, ttpMessage.getCommitment(), range);
```

The range proof consists of 22 variables. They can be retrieved by using the following getters:
- `rangeProof.getcPrime()`
- `rangeProof.getcPrime1()`
- `rangeProof.getcPrime2()`
- `rangeProof.getcPrime3()`
- `rangeProof.getSqrProof3().getF()`
- `rangeProof.getSqrProof3().getECProof().getC()`
- `rangeProof.getSqrProof3().getECProof().getD()`
- `rangeProof.getSqrProof3().getECProof().getD1()`
- `rangeProof.getSqrProof3().getECProof().getD2()`
- `rangeProof.getSqrProof4().getF()`
- `rangeProof.getSqrProof4().getECProof().getC()`
- `rangeProof.getSqrProof4().getECProof().getD()`
- `rangeProof.getSqrProof4().getECProof().getD1()`
- `rangeProof.getSqrProof4().getECProof().getD2()`
- `rangeProof.getEcProof2().getC()`
- `rangeProof.getEcProof2().getD()`
- `rangeProof.getEcProof2().getD1()`
- `rangeProof.getEcProof2().getD2()`
- `rangeProof.getU()`
- `rangeProof.getV()`
- `rangeProof.getX()`
- `rangeProof.getY()`

In the precompiled smart contract we expect the range proof to be the above variables (in this order), separated by commas.

#### Validating proofs by calling the precompiled smart contract

Another way to verify a range proof is by calling the precompiled smart contract that is embedded in our modified Geth client. Make sure that the modified Geth is running (see the first section of this instruction).

You first need to set up an Ethereum client in Java (i.e. via web3j). Once set up, you can call the precompiled contract at address `0x0000000000000000000000000000000000000009`. You can call the following method to validate the range proof:
```java
validate(lower, upper, commitment, rangeProof);
```
which returns `true` iff the range proof is valid for this range and commitment.

It is also possible to call the smart contract from uPort by instantiating another web3 instance that connects to the local modified Geth client. Please refer to the uPort documentation for calling smart contracts. Once instantiated by providing an ABI (embedded in the code snippet below), you can call the `validate` method on the smart contract as illustrated in the snippet above.

For testing purposes you can also call the precompiled smart contract from the command line. Start the modified Geth client with the argument `console`, or open a new terminal using `geth attach` to be able to execute commands from the command line.
First, instantiate the smart contract:
```
var precompiled = eth.contract([{"constant":true,"inputs":[{"name":"lower","type":"uint64"},{"name":"upper","type":"uint64"},{"name":"commitment","type":"string"},{"name":"proof","type":"string"}],"name":"validate","outputs":[{"name":"","type":"bool"}],"payable":false,"stateMutability":"view","type":"function"}]).at("0x0000000000000000000000000000000000000009");
```
this always returns `undefined`. Now, call the contract by filling in the variables below:
```
precompiled.validate(lower, upper, "commitment", "rangeProof");
```
which returns `true` iff the range proof is valid for this range and commitment.

Please note that the variables `commitment` and `rangeProof` should be the comma separated combination of the `BigInteger` variables specified in this instruction. The commitment is only the first four variables of the TTPMessage.
