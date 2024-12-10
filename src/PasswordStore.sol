// SPDX-License-Identifier: MIT
pragma solidity 0.8.18; // q is this the correct version?

/*
 * @author not-so-secure-dev
 * @title PasswordStore
 * @notice This contract allows you to store a private password that others won't be able to see. 
 * You can update your password at any time.
 */
contract PasswordStore {
    /**
     * ERRORS
     */
    error PasswordStore__NotOwner();

    /**
     * STATE VARIABLE
     */

    address private s_owner;
    // @audit the s_password is not indeed private! This is not a secure place to store your password
    // All data on chain is actually public data.
    string private s_password;

    /**
     * EVENTS
     */
    event SetNetPassword();

    constructor() {
        s_owner = msg.sender;
    }

    /*
     * @notice This function allows the owner to set a new password.
     * @param newPassword The new password to set.
     */
    // q can non-owner be able to set the password?
    // q should a non-owner be able to set the password?
    // @audit any user can set the password.
    // missing access control
    function setPassword(string memory newPassword) external {
        s_password = newPassword;
        emit SetNetPassword();
    }

    /*
     * @notice This allows only the owner to retrieve the password.
     // @audit There is no newPassword parameter
     * @param newPassword The new password to set.
     */
    function getPassword() external view returns (string memory) {
        if (msg.sender != s_owner) {
            revert PasswordStore__NotOwner();
        }
        return s_password;
    }
}
