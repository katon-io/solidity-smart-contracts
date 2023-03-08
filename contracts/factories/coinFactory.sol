// contracts/common/MayBeFreezable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../coin/Coin.sol";
import "../asset/Collection.sol";

contract CoinFactory {
    event CoinIssued(address _contractAddress);

    constructor() {}

    function issueCoin(
        address owner_,
        string memory name_,
        string memory ticker_,
        uint256 initialSupply_,
        address[] memory defaultOperators_,
        Config memory config_,
        address trustedForwarder_
    ) public {
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
