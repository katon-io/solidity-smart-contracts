// contracts/common/MayBeWipeable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MayBeFreezable.sol";

abstract contract MayBeWipeable is Ownable, MayBeFreezable {
    bool private _isWipeable;

    constructor(bool isWipeable) {
        _checkIsFreezable();
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
}
