// contracts/common/MayBeFreezable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../coin/Coin.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CoinFactory is Ownable {
    event CoinIssued(address _contractAddress);

    address payable _katonAddress;

    constructor(address payable katonAddress_) {
        _katonAddress = katonAddress_;
    }

    function issueCoin(
        address owner_,
        string memory name_,
        string memory ticker_,
        uint256 initialSupply_,
        address[] memory defaultOperators_,
        Config memory config_,
        address trustedForwarder_
    ) public payable {
        if (msg.value > 0) {
            _katonAddress.transfer(msg.value);
        }

        Coin coin = new Coin(
            owner_,
            name_,
            ticker_,
            initialSupply_,
            defaultOperators_,
            config_,
            trustedForwarder_
        );
        emit CoinIssued(address(coin));
    }
}
