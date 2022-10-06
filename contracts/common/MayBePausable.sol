// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract MayBePausable is Ownable, Pausable {
    bool private _isPausable;
    mapping(address => bool) private _accountFrozen;

    constructor(bool isPausable) {
        _isPausable = isPausable;
    }

    function pausable() public view returns (bool) {
        return _isPausable;
    }

    function paused() public view virtual override returns (bool) {
        if (_isPausable) {
            return super.paused();
        } else {
            return false;
        }
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
