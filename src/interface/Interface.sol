// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20 {
    function transfer(address to, uint amt) external returns (bool);
    function symbol() external view returns (string memory);
    function balanceOf(address who) external view returns (uint);
}

interface Deployer{
    function isSmartWalletAdmin(address admin) external view returns (bool);
    function isHotWalletAdmin(address admin) external view returns (bool);
}