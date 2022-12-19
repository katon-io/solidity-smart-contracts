// contracts/common/MayBePausable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "./MayBeUpgradeable.sol";

abstract contract MayBePausable is Ownable, MayBeUpgradeable, Pausable {
    bool private _isPausable;

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

    function setPausable(bool isPausable) public onlyOwner whenUpgradeable {
        if (isPausable) {
            require(
                _isPausable != isPausable,
                "Pausable: The contract is already pausable"
            );
        } else {
            require(
                _isPausable != isPausable,
                "Pausable: The contract is already not pausable"
            );
        }
        _isPausable = isPausable;
    }
}
