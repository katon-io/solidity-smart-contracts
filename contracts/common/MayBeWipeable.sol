// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MayBeFreezable.sol";

abstract contract MayBeWipeable is ERC777, Ownable, MayBeFreezable {
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

    function _checkIsWipeable() internal view virtual  {
        require(_isWipeable, "Wipeable: The contract should be wipeable");
    }

    function wipe(address account) public onlyOwner whenWipeable whenAccountFrozen(account) {
        _burn(account, balanceOf(account), "", "");
    }
}
