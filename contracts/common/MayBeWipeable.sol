// contracts/common/MayBeWipeable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MayBeFreezable.sol";
import "./MayBeUpgradeable.sol";

abstract contract MayBeWipeable is Ownable, MayBeUpgradeable, MayBeFreezable {
    bool private _isWipeable;

    constructor(bool isWipeable) {
        if(isWipeable) {
            _checkIsFreezable();
        }
        _isWipeable = isWipeable;
    }

    function wipeable() public view returns (bool) {
        return _isWipeable;
    }

    modifier whenWipeable() {
        _checkIsWipeable();
        _;
    }

    function _checkIsWipeable() internal view virtual {
        require(_isWipeable, "Wipeable: The contract should be wipeable");
    }

    function setWipeable(bool isWipeable) public onlyOwner whenUpgradeable {
        require(_isWipeable == isWipeable && _isWipeable, "Wipeable: The contract is already wipeable");
        require(_isWipeable == isWipeable && !_isWipeable, "Wipeable: The contract is already not wipeable");
        _isWipeable = isWipeable;
    }
}
