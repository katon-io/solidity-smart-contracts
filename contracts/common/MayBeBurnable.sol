// contracts/common/MayBeBurnable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MayBeUpgradeable.sol";

abstract contract MayBeBurnable is Ownable, MayBeUpgradeable {
    bool private _isBurnable;

    constructor(bool isBurnable) {
        _isBurnable = isBurnable;
    }

    function burnable() public view returns (bool) {
        return _isBurnable;
    }

    modifier whenBurnable() {
        _checkIsBurnable();
        _;
    }

    function _checkIsBurnable() internal view virtual {
        require(burnable(), "Burnable: The contract is not burnable");
    }

    function setBurnable(bool isBurnable) public onlyOwner whenUpgradeable {
        if (isBurnable) {
            require(
                _isBurnable != isBurnable,
                "Burnable: The contract is already burnable"
            );
        } else {
            require(
                _isBurnable != isBurnable,
                "Burnable: The contract is already not burnable"
            );
        }
        _isBurnable = isBurnable;
    }
}
