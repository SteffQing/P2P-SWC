// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/deployer/WAlletDeployer.sol";
import "../src/smart-wallet/SmartWalletV2.sol";
import "../src/smart-wallet/HotWallet.sol";
import "../src/interface/Interface.sol";

contract HotWalletTest is Test {
    HotWallet hotWallet;
    address deployer = address(this);
    address admin = address(0x111);
    address user = address(0x222);

    // event SentETH(address sender, uint amount, uint fee);
    // event SentToken(address sender, string symbol, uint amount, uint fee);

    function setUp() public {
        hotWallet = new HotWallet();
    }

    // function testWithdrawETH() public {
    //     vm.deal(address(hotWallet), 2 ether);
    //     vm.prank(admin);
    //     hotWallet.withdrawETH(user, payable(user), 1 ether, 0.1 ether);
    // }
}
