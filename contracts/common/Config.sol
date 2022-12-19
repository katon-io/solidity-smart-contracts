// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

struct Config {
    bool isPausable_;
    bool isFreezable_;
    bool isWipeable_;
    bool isMintable_;
    bool isBurnable_;
    bool isUpgradeable;
}