### [H1-#] Storing the password on-chain is visible to everyone, it's no longer private.

**Description:** All data stored on-chain is visible to anyone and can be read directly from the blockchain. The `PasswordStor::s_password` variable is intended to be private variable and can only be retrieved by the owner calling the `PasswordStore::getPassword` function on the contract.

We show one such method of reading any data off chain below.

**Impact:** Anyone can read the private password severely breaking the functionality of the protocol

**Proof of Concept:** (Proof of Code)
The below test case shows anyone can read the password directly from the blockchain.
1. Create a local running chain

```bash
make anvil
```

1. Deploy the contract to the chain
 
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

**Recommended Mitigation:** Due to this, thr overall architecture should be rethought. One could encrypt the password off-chain, and the store the encrypted password on-chain. This will require the user to remember another password off-chain to decrypt the password. However you would also want to remove the view function as you wn't want the user to accidentally send a transaction with the password that decrypt your password


### [H2-#] `PasswordStore::setPassword` has no access control, meaning a non-owner could change the password.

**Description:** The `PasswordStore::setPassword`  function is an `external` function. However, the natspec of the function and overall purpose of the smart contract is that `The function allows only the owner to set a new password.`

```javascript
    function setPassword(string memory newPassword) external {
@>        // @audit - There are no access control
        s_password = newPassword;
        emit SetNetPassword();
    }
```

**Impact:** Anyone can set/change the password of the contract, severely breaking the contracts intended functionality.

**Proof of Concept:** Add the following to the `PasswordStore.t.sol`

<details>
<summary>Code</summary>

```javascript
    function test_anyone_can_set_password(address randomAddress) public {
        vm.assume(randomAddress != owner);
        vm.prank(randomAddress);
        string memory expectedPassword = "anyBodyPassword";
        passwordStore.setPassword(expectedPassword);

        vm.prank(owner);
        string memory actuallyPassword = passwordStore.getPassword();

        assertEq(actuallyPassword, expectedPassword);
    }
```

</details>

**Recommended Mitigation:** Add access control condition to `PasswordStore::setPassword`

```javascript
    if (msg.sender != owner) {
        revert PasswordStore__NotOwner();
    }
```


### [NC-#] Incorrect NatSpec for `PasswordStore::getPassword` function

**Description:** The `PasswordStore::getPassword` function has an incorrect NatSpec comment for its parameter.

```javascript
    /*
     * @notice This allows only the owner to retrieve the password.
@>   * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
```

The `PasswordStore::getPassword` actual function signature is `getPassword()` but the NatSpec comment indicates it should be `getPassword(string)`.

**Impact:** The NatSpec comment is incorrect and misleading.

**Recommended Mitigation:** Remove the incorrect NatSpec line for the non-existent parameter.

```diff
-    * @param newPassword The new password to set.
```

This correction ensures that the NatSpec accurately reflects the actual function signature and parameters.

