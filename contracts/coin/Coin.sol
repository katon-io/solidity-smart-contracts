// contracts/GLDToken.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC777/ERC777.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "../common/MayBeWipeable.sol";
import "../common/MayBePausable.sol";
import "../common/MayBeFreezable.sol";
import "../common/MayBeMintable.sol";

contract Coin is ERC777, Ownable, MayBePausable, MayBeFreezable, MayBeWipeable, MayBeMintable {
    constructor(
        string memory name,
        string memory ticker,
        uint256 initialSupply,
        address[] memory defaultOperators,
        bool isPausable,
        bool isFreezable,
        bool isWipeable,
        bool isMintable
    )
        ERC777(name, ticker, defaultOperators)
        MayBeFreezable(isFreezable)
        MayBeWipeable(isWipeable)
        MayBePausable(isPausable)
        MayBeMintable(isMintable)
    {
        _mint(_msgSender(), initialSupply, "", "");
    }

    function send(
        address recipient,
        uint256 amount,
        bytes memory data
    )
        public
        override
        whenUnpaused
        whenAccountNotFrozen(_msgSender())
        whenAccountNotFrozen(recipient)
    {
        super.send(recipient, amount, data);
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        whenUnpaused
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
        whenUnpaused
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
        whenUnpaused
        whenAccountNotFrozen(_msgSender())
        whenAccountNotFrozen(recipient)
        returns (bool)
    {
        return super.transferFrom(holder, recipient, amount);
    }
}
