// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

abstract contract MayBeMintable is ERC777, Ownable {
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

    function mint(
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public onlyOwner whenMintable {
        super._mint(_msgSender(), amount, userData, operatorData, false);
    }
}
