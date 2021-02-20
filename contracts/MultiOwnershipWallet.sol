// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

contract MultiOwnershipWallet {

    address[] public owners;
    mapping (address => bool) public isOwner;
    mapping (address => ufixed) public ownership;

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and % ownership breakdown.
    /// @param _owners List of initial owners.
    /// @param _ownership Number of required confirmations.
    function MultiSigWallet(address[] memory _owners, ufixed[] memory _ownership)
        public
    {
        for (uint i=0; i<_owners.length; i++) {
            if (isOwner[_owners[i]] || _owners[i] == address(0))
                revert();
            isOwner[_owners[i]] = true;
            ownership[_owners[i]] = _ownership[i];
        }

        owners = _owners;
    }
}