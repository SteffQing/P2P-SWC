// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/smart-wallet/Relayer.sol";
import "../src/lib/ERC20.sol";

contract RelayerTest is Test {
    Relayer public relayer;
    address relayerAddress;

    address payable victim;
    uint256 victimPkey;
    address receiver;
    address owner;

    function setUp() public {
        (address victimAddr, uint256 victimkey) = makeAddrAndKey("victim");
        receiver = makeAddr("receiver");
        owner = address(this);
        victim = payable(victimAddr);
        victimPkey = victimkey;

        vm.startPrank(owner);
        relayer = new Relayer(owner);
        relayerAddress = address(relayer);
        vm.stopPrank();

        vm.deal(victim, 1 ether);
    }

    function test_sendETH_withAuthorization() public {
        uint256 amount = 0.1 ether;
        uint256 receiverBalanceBefore = receiver.balance;

        // Attach delegation (EIP-7702 style)
        vm.signAndAttachDelegation(relayerAddress, victimPkey);

        bytes memory code = address(victim).code;
        require(code.length > 0, "no code written to victim");

        vm.startPrank(owner);
        Relayer(victim).send(victim, receiver, amount, address(0));
        vm.stopPrank();

        assertEq(receiver.balance, receiverBalanceBefore + amount);
    }

    // function test_sendDAI_withAuthorization() public {
    //     uint256 amount = 100e18;
    //     uint256 receiverBalanceBefore = DAI.balanceOf(receiver);

    //     vm.signAndAttachDelegation(relayerAddress, victimPkey);

    //     vm.startPrank(relayerAddress);
    //     relayer.send(victim, receiver, amount, address(DAI));
    //     vm.stopPrank();

    //     assertEq(DAI.balanceOf(receiver), receiverBalanceBefore + amount);
    // }

    function test_cannotSendWithoutAuthorization() public {
        uint256 amount = 0.05 ether;

        vm.expectRevert("Not the owner");

        vm.startPrank(relayerAddress);
        relayer.send(victim, receiver, amount, address(0));
        vm.stopPrank();
    }

    function test_eventEmitted() public {
        uint256 amount = 0.02 ether;

        vm.signAndAttachDelegation(relayerAddress, victimPkey);

        vm.expectEmit(true, true, true, true);
        emit Relayer.TransactionSent(victim, receiver, amount, address(0));

        vm.startPrank(owner);
        Relayer(victim).send(victim, receiver, amount, address(0));
        vm.stopPrank();
    }

    function test_delegateAuthorization() public {
        Vm.SignedDelegation memory signedDelegation = vm.signAndAttachDelegation(relayerAddress, victimPkey);

        assertEq(signedDelegation.implementation, relayerAddress);
    }

    /// forge-config: default.allow_internal_expect_revert = true
    function test_removeDelegation() public {
        Vm.SignedDelegation memory signedDelegation = vm.signAndAttachDelegation(relayerAddress, victimPkey);

        assertEq(signedDelegation.implementation, relayerAddress);

        uint256 amount = 0.1 ether;
        vm.startPrank(owner);
        Relayer(victim).send(victim, receiver, amount, address(0));
        vm.stopPrank();

        assertEq(receiver.balance, amount);

        // Remove delegation
        vm.signAndAttachDelegation(address(0), victimPkey);
        bytes memory code = address(victim).code;
        assertEq(code.length, 0, "Delegation not removed");

        // Try to send again, should fail
        vm.expectRevert();
        vm.startPrank(owner);
        Relayer(victim).send(victim, receiver, amount, address(0));
        vm.stopPrank();
    }
}
