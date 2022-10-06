// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MayBeMintable is Ownable {
    bool private _isMintable;
    mapping(address => bool) private _accountFrozen;

    constructor(bool isMintable) {
        _isMintable = isMintable;
    }

    function mintable() public view returns (bool) {
        return _isMintable;
    }

    modifier whenMintable() {
        _checkIsMintable();
        _;
    }

    function _checkIsMintable() internal view virtual {
        require(mintable(), "Mintable: The contract is not mintable");
    }
}
