// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20, Deployer} from "../interface/Interface.sol";

contract HotWallet {
    Deployer private immutable deployer;

    constructor() {
        deployer = Deployer(msg.sender);
    }

    modifier onlyAdmin() {
        require(deployer.isHotWalletAdmin(msg.sender), "Not the admin");
        _;
    }

    event SentETH(address sender, uint amount, uint fee);
    event SentToken(address sender, string symbol, uint amount, uint fee);

    receive() external payable {}

    function withdrawETH(
        address sender,
        address payable recipient,
        uint256 amount,
        uint fee
    ) external onlyAdmin {
        require(recipient != address(0));
        uint total = amount + fee;
        require(getEthBalance() >= total, "Low ETH balance to withdraw");
        (bool _success, ) = address(deployer).call{value: fee}("");
        require(_success, "Fee withdrawal failed");
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "withdraw failed");
        emit SentETH(sender, amount, fee);
    }

    function withdrawERC20Token(
        IERC20 token,
        address sender,
        address to,
        uint256 amount,
        uint fee
    ) external onlyAdmin {
        require(to != address(0), "cannot send to address 0");
        uint total = amount + fee;
        require(
            getErc20Balance(token) >= total,
            "Low token balance to withdraw"
        );
        require(
            token.transfer(address(deployer), fee),
            "Token transfer failed"
        );
        require(token.transfer(to, amount), "Token transfer failed");
        emit SentToken(sender, token.symbol(), amount, fee);
    }

    function getEthBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getErc20Balance(IERC20 token) public view returns (uint) {
        return token.balanceOf(address(this));
    }
}
