// SPDX-License-Identifier: MIT
pragma solidity ^0.7.4;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract MultiOwnershipWallet {
    address payable[] public owners;
    uint256 public totalOwnership;

    uint256 public requiredConfirmationPercentageForDistribution;

    mapping(uint256 => Distribution) public distributions;
    mapping(address => bool) public isOwner;
    mapping(address => uint256) public ownership;
    mapping(uint256 => mapping(address => bool)) public confirmations;

    uint256 public distributionCount;

    struct Distribution {
        uint256 value;
        bool executed;
    }

    event DistributionInitiated(uint256 indexed distributionId);

    /*
     * Public functions
     */
    /// @dev Contract constructor sets initial owners and % ownership breakdown.
    /// @param _owners List of initial owners.
    /// @param _ownership Number of required confirmations.
    constructor(
        address payable[] memory _owners,
        uint256[] memory _ownership,
        uint256 _requiredConfirmationPercentageForDistribution
    ) {
        require(
            _owners.length == _ownership.length,
            "Length of owners and ownership must match."
        );

        require(
            _requiredConfirmationPercentageForDistribution > 0,
            "requiredConfirmationPercentageForDistribution must be greater than 0"
        );

        for (uint256 i = 0; i < _owners.length; i++) {
            if (isOwner[_owners[i]]) {
                revert("Address was included more than once.");
            }
            if (_owners[i] == address(0)) {
                revert("List of owners cannot include null address");
            }

            isOwner[_owners[i]] = true;
            ownership[_owners[i]] = _ownership[i];
            totalOwnership += _ownership[i];
        }

        owners = _owners;
        requiredConfirmationPercentageForDistribution = _requiredConfirmationPercentageForDistribution;
    }

    fallback() external payable {}
    receive() external payable {}
    
    function submitDistribution(uint256 value)
        public
        returns (uint256 distributionId)
    {
        distributionId = distributionCount;

        distributions[distributionId] = Distribution({
            value: value,
            executed: false
        });

        distributionCount += 1;
        emit DistributionInitiated(distributionId);

        return distributionId;
    }

    function confirmDistribution(uint256 distributionId) public {
        confirmations[distributionId][msg.sender] = true;

        executeDistribution(distributionId);
    }

    function denyDistribution(uint256 distributionId) public {
        confirmations[distributionId][msg.sender] = false;
    }

    function executeDistribution(uint256 distributionId) public {
        if (!isConfirmed(distributionId)) {
            return;
        }

        Distribution memory distribution = distributions[distributionId];
        distribution.executed = true;

        for (uint256 i = 0; i < owners.length; i++) {
            uint256 payment = distribution.value * ownership[owners[i]] / totalOwnership;

            require(payment != 0, "Account is not due payment");

            Address.sendValue(owners[i], payment);
        }
    }

    function isConfirmed(uint256 distributionId) public view returns (bool) {
        uint256 totalConfirmationPercentage = 0;
        for (uint256 i = 0; i < owners.length; i++) {
            if (confirmations[distributionId][owners[i]]) {
                totalConfirmationPercentage += ownership[owners[i]];
            }
            if (
                totalConfirmationPercentage >=
                requiredConfirmationPercentageForDistribution
            ) {
                return true;
            }
        }

        return false;
    }
}
