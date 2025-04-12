// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/deployer/WAlletDeployer.sol";
import "../src/smart-wallet/SmartWalletV2.sol";
import "../src/smart-wallet/HotWallet.sol";
import "../src/interface/Interface.sol";

contract WAAS_DeployerTest is Test {
    WAAS_Deployer deployer;
    address owner = address(0x123);
    address smartAdmin = address(0x456);
    address hotAdmin = address(0x789);
    address deployAdmin = address(0xABC);
    address testUser = address(0xDEF);

    // event WalletCreated(address indexed wallet);

    function setUp() public {
        vm.prank(owner);
        deployer = new WAAS_Deployer(smartAdmin, hotAdmin, deployAdmin);
    }

    function testDeployWallet() public {
        vm.prank(deployAdmin);
        uint256 gasStart = gasleft();
        // vm.expectEmit(true, false, false, true);
        // emit WalletCreated(address(0)); // We don't know the exact address in advance
        deployer.deployWallet();
        uint256 gasUsed = gasStart - gasleft();
        emit log_named_uint("Gas used for deployWallet()", gasUsed);
    }

    function testChangeOwner() public {
        vm.prank(owner);
        deployer.changeOwner(testUser);
    }

    function testChangeSmartAdmin() public {
        vm.prank(owner);
        deployer.changeSmartAdmin(testUser);
        assertTrue(deployer.isSmartWalletAdmin(testUser));
    }

    function testChangeHotAdmin() public {
        vm.prank(owner);
        deployer.changeHotAdmin(testUser);
        assertTrue(deployer.isHotWalletAdmin(testUser));
    }

    function testChangeDeployerAdmin() public {
        vm.prank(owner);
        deployer.changeDeployerAdmin(testUser);
    }

    function testWithdrawFees() public {
        vm.deal(address(deployer), 1 ether);
        vm.prank(owner);
        deployer.withdrawFees(address(0));
        assertEq(owner.balance, 1 ether);
    }
}
