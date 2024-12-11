---
title: Protocol Audit Report
author: Onowu Chris
date: December 7, 2024
header-includes:
  - \usepackage{titling}
  - \usepackage{graphicx}
---

\begin{titlepage}
    \centering
    \begin{figure}[h]
        \centering
        \includegraphics[width=0.5\textwidth]{logo.pdf} 
    \end{figure}
    \vspace*{2cm}
    {\Huge\bfseries Protocol Audit Report\par}
    \vspace{1cm}
    {\Large Version 1.0\par}
    \vspace{2cm}
    {\Large\itshape Onowu Chris\par}
    \vfill
    {\large \today\par}
\end{titlepage}

\maketitle

<!-- Your report starts here! -->

Prepared by: [Onowu Chris](https://cyfrin.io)
Lead Security Researcher: 
- Onowu Chris

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
- [Findings](#findings)
  - [High](#high)
    - [\[H1-#\] Storing the password on-chain is visible to everyone, it's no longer private.](#h1--storing-the-password-on-chain-is-visible-to-everyone-its-no-longer-private)
    - [\[H2-#\] `PasswordStore::setPassword` has no access control, meaning a non-owner could change the password.](#h2--passwordstoresetpassword-has-no-access-control-meaning-a-non-owner-could-change-the-password)
  - [Informational](#informational)

# Protocol Summary

PasswordStore is a protocol dedicated to storage and retrieval of a user's password. The protocol is designed to be used by a single user, and is not designed to be used by multiple users. Only the owner should be able to set and retrieve this password.

# Disclaimer

The Chris team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 
**The findings described in this document corresponds to the following commit hash**

commit hash
```
    7d55682ddc4301a7b13ae9413095feffd9924566
```
## Scope 

```
./src/
#-- PasswordStore.sol
```

## Roles

- Owner: The user who can set the password and read the password.
- Outsides: No one else should be able to set or read the password.

# Executive Summary

**Add some notes of how the audit went, types of things found etc**
**Hours spent with numbers of auditors using what tools**

## Issues found

| Severity | Numbers of issues found |
| -------- | ----------------------- |
| High     | 2                       |
| Medium   | 0                       |
| Low      | 0                       |
| Info     | 1                       |
| Total    | 3                       |

# Findings
## High

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

## Informational

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
