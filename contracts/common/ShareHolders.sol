// contracts/common/MayBeFreezable.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct ShareHolders {
    address katonAddress_;
    uint96 katonFeesPercentage_;
    address projectAddress_;
    uint96 projectFeesPercentage_;
    address accountAddress_;
    uint96 accountFeesPercentage_;
}
