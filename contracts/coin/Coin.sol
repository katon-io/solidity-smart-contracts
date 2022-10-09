// contracts/Coin.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../common/MayBeWipeable.sol";
import "../common/MayBePausable.sol";
import "../common/MayBeFreezable.sol";
import "../common/MayBeMintable.sol";
import "../common/MayBeBurnable.sol";

contract Coin is
    ERC777,
    Ownable,
    MayBePausable,
    MayBeFreezable,
    MayBeWipeable,
    MayBeMintable,
    MayBeBurnable
{
    struct Config {
        bool isPausable_;
        bool isFreezable_;
        bool isWipeable_;
        bool isMintable_;
        bool isBurnable_;
    }

    constructor(
        string memory name_,
        string memory ticker_,
        uint256 initialSupply_,
        address[] memory defaultOperators_,
        Config memory config_
    )
        ERC777(name_, ticker_, defaultOperators_)
        MayBeFreezable(config_.isFreezable_)
        MayBeWipeable(config_.isWipeable_)
        MayBePausable(config_.isPausable_)
        MayBeMintable(config_.isMintable_)
        MayBeBurnable(config_.isBurnable_)
    {
        _mint(_msgSender(), initialSupply_, "", "");
    }

    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    )
        public
        override
        whenNotPaused
        whenAccountNotFrozen(_msgSender())
        whenAccountNotFrozen(recipient)
    {
        super.send(recipient, amount, data);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        whenNotPaused
        whenAccountNotFrozen(_msgSender())
        whenAccountNotFrozen(recipient)
        returns (bool)
    {
        return super.transfer(recipient, amount);
    }

    function burn(uint256 amount, bytes memory data)
        public
        override
        onlyOwner
        whenNotPaused
        whenAccountNotFrozen(_msgSender())
    {
        super.burn(amount, data);
    }

    function transferFrom(
        address holder,
        address recipient,
        uint256 amount
    )
        public
        virtual
        override
        onlyOwner
        whenNotPaused
        whenAccountNotFrozen(_msgSender())
        whenAccountNotFrozen(recipient)
        returns (bool)
    {
        return super.transferFrom(holder, recipient, amount);
    }

    function mint(
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public onlyOwner whenMintable {
        super._mint(_msgSender(), amount, userData, operatorData, false);
    }

    function burn(
        uint256 amount,
        bytes memory userData,
        bytes memory operatorData
    ) public onlyOwner whenBurnable {
        super._burn(_msgSender(), amount, userData, operatorData);
    }

    function wipe(address account)
        public
        onlyOwner
        whenWipeable
        whenAccountFrozen(account)
    {
        _burn(account, balanceOf(account), "", "");
    }
}
