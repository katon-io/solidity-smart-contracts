// contracts/common/MayBeFreezable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./MayBeUpgradeable.sol";

abstract contract MayBeFreezable is Ownable, MayBeUpgradeable {
    bool private _isFreezable;
    mapping(address => bool) private _accountFrozen;

    constructor(bool isFreezable) {
        _isFreezable = isFreezable;
    }

    function freezable() public view returns (bool) {
        return _isFreezable;
    }

    modifier whenFreezable() {
        _checkIsFreezable();
        _;
    }

    function _checkIsFreezable() internal view virtual {
        require(freezable(), "Freezable: The contract should be freezable");
    }

    modifier whenAccountFrozen(address account) {
        if (freezable()) {
            _checkAccountFrozen(account);
        }
        _;
    }

    modifier whenAccountNotFrozen(address account) {
        if (freezable()) {
            _checkAccountNotFrozen(account);
        }
        _;
    }

    function _checkAccountFrozen(address account) internal view virtual {
        require(
            _accountFrozen[account] == true,
            "Freezable: Account is not frozen"
        );
    }

    function _checkAccountNotFrozen(address account) internal view virtual {
        require(
            _accountFrozen[account] != true,
            "Freezable: Account is frozen"
        );
    }

    function addFrozenAccount(address account) public onlyOwner whenFreezable {
        _accountFrozen[account] = true;
    }

    function removeFrozenAccount(
        address account
    ) public onlyOwner whenFreezable {
        _accountFrozen[account] = false;
    }

    function setFreezable(bool isFreezable) public onlyOwner whenUpgradeable {
        if (isFreezable) {
            require(
                _isFreezable != isFreezable,
                "Freezable: The contract is already freezable"
            );
        } else {
            require(
                _isFreezable != isFreezable,
                "Freezable: The contract is already not freezable"
            );
        }
        _isFreezable = isFreezable;
    }
}
