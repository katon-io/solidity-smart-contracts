// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MayBeBurnable is Ownable {
    bool private _isBurnable;
    mapping(address => bool) private _accountFrozen;

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
}
