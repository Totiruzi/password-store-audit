### [S-#] Storing the password on-chain is visible to everyone, it's no longer private.

**Description:** All data stored on-chain is visible to anyone and can be read directly from the blockchain. The `PasswordStor::s_password` variable is intended to be private variable and can only be retrieved by the owner calling the `PasswordStore::getPassword` function on the contract.

We show one such method of reading any data off chain below.

**Impact:** Anyone can read the private password severely breaking the functionality of the protocol

**Proof of Concept:** 
The below test case shows anyone can read the password directly from the blockchain.
1. Create a local running chain

```bash
make anvil
```

1. Deploy the contract to the chain
2. 
```bash
make deploy
```

1. Run the storage tool
We use 1 because that is the storage slot for the `PasswordStore::s_password` in the contract.

```bash
cast storage <Contract Address> 1 --rpc-url http://127.0.0.
1:8545
```

You will get an output that looks like this

```
0x7365637265746550617373776f7264000000000000000000000000000000001e
```

You can then parse that hex to a string with:

```bash
cast parse-bytes32-string 0x7365637265746550617373776f7264000000000000000000000000000000001e
```

And get an output of:

```bash
secretePassword
```

**Recommended Mitigation:** 