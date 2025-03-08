// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {SmartWallet} from "../smart-wallet/SmartWalletV2.sol";
import {HotWallet} from "../smart-wallet/HotWallet.sol";
import {IERC20} from "../interface/Interface.sol";

contract WAAS_Deployer {
    address public immutable HotWalletAddress;

    address private Owner = msg.sender;
    address private SmartWalletAdmin;
    address private HotWalletAdmin;
    address private DeployerAdmin;

    modifier onlyOwner() {
        require(msg.sender == Owner, "Not the owner");
        _;
    }

    modifier onlyDeployerAdmin() {
        require(msg.sender == DeployerAdmin, "Not the deployment admin!");
        _;
    }

    event WalletCreated(address indexed wallet);

    constructor(address _smartAdmin, address _hotAdmin, address _deployAdmin) {
        HotWalletAddress = address(new HotWallet());
        SmartWalletAdmin = _smartAdmin;
        HotWalletAdmin = _hotAdmin;
        DeployerAdmin = _deployAdmin;
    }

    receive() external payable {}

    // Main Function
    function deployWallet() external onlyDeployerAdmin {
        address wallet = address(new SmartWallet(HotWalletAddress));
        emit WalletCreated(wallet);
    }

    // Write Functions
    function changeOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is the zero address");
        Owner = newOwner;
    }
    function changeSmartAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "New admin is the zero address");
        SmartWalletAdmin = newAdmin;
    }
    function changeHotAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "New admin is the zero address");
        HotWalletAdmin = newAdmin;
    }
    function changeDeployerAdmin(address newAdmin) external onlyOwner {
        require(newAdmin != address(0), "New admin is the zero address");
        DeployerAdmin = newAdmin;
    }

    function withdrawFees(address _token) external onlyOwner {
        if (_token == address(0)) {
            uint balance = address(this).balance;
            (bool success, ) = Owner.call{value: balance}("");
            require(success, "transfer failed");
        } else {
            IERC20 token = IERC20(_token);
            uint balance = token.balanceOf(address(this));
            require(token.transfer(Owner, balance), "Token transfer failed");
        }
    }

    // Read Functions
    function isSmartWalletAdmin(address _admin) public view returns (bool) {
        return SmartWalletAdmin == _admin;
    }
    function isHotWalletAdmin(address _admin) public view returns (bool) {
        return HotWalletAdmin == _admin;
    }
}
