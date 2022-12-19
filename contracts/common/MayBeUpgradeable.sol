// contracts/common/MayBeWipeable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MayBeUpgradeable is Ownable {
    bool private _isUpgradeable;

    constructor(bool isUpgradeable) {
        _isUpgradeable = isUpgradeable;
    }

    function upgradeable() public view returns (bool) {
        return _isUpgradeable;
    }

    modifier whenUpgradeable() {
        _checkIsUpgradeable();
        _;
    }

    function _checkIsUpgradeable() internal view virtual {
        require(upgradeable(), "Upgradeable: The contract is not upgradeable");
    }
}
