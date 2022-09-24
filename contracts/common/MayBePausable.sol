// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

abstract contract MayBePausable is ERC777, Ownable, Pausable {
    bool private _isPausable;
    mapping(address => bool) private _accountFrozen;

    constructor(bool isPausable) {
        _isPausable = isPausable;
    }

    modifier whenUnpaused() {
        if(this.pausable()) {
            _requireNotPaused();
        }
        _;
    }

    function pausable() public view returns (bool) {
        return _isPausable;
    }

    function paused() public view virtual override returns (bool) {
        if(_isPausable) {
            return super.paused();
        } else {
            return false;
        }
    }
}
