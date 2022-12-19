// contracts/common/MayBeMintable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MayBeUpgradeable.sol";

abstract contract MayBeMintable is Ownable, MayBeUpgradeable {
    bool private _isMintable;

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

    function setMintable(bool isMintable) public onlyOwner whenUpgradeable {
        require(_isMintable == isMintable && _isMintable, "Mintable: The contract is already mintable");
        require(_isMintable == isMintable && !_isMintable, "Mintable: The contract is already not mintable");
        _isMintable = isMintable;
    }
}
