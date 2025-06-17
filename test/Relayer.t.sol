// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.21;

import "forge-std/Test.sol";
import "../src/smart-wallet/Relayer.sol";
import "../src/lib/ERC20.sol";

contract RelayerTest is Test {
    Relayer public relayer;
    address relayerAddress;

    address victim;
    uint256 victimPkey;
    address receiver;
    address owner;

    ERC20 constant DAI = ERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    address constant DAI_WHALE = 0x28C6c06298d514Db089934071355E5743bf21d60;

    function setUp() public {
        (victim, victimPkey) = makeAddrAndKey("victim");
        receiver = makeAddr("receiver");
        owner = address(this);

        vm.startPrank(owner);
        relayer = new Relayer(owner);
        relayerAddress = address(relayer);
        vm.stopPrank();

        // Fund victim with ETH
        vm.deal(victim, 1 ether);

        // Fund victim with DAI
        vm.startPrank(DAI_WHALE);
        DAI.transfer(victim, 500e18);
        vm.stopPrank();
    }

    function test_sendETH_withAuthorization() public {
        uint256 amount = 0.1 ether;
        uint256 receiverBalanceBefore = receiver.balance;

        // Attach delegation (EIP-7702 style)
        vm.signAndAttachDelegation(relayerAddress, victimPkey);

        bytes memory code = address(victim).code;
        require(code.length > 0, "no code written to victim");

        // Relayer executes on behalf of victim
        // vm.startPrank(relayerAddress);
        vm.broadcast(owner);
        Relayer(victim).send(victim, receiver, amount, address(0));
        vm.stopPrank();

        assertEq(receiver.balance, receiverBalanceBefore + amount);
    }

    function test_sendDAI_withAuthorization() public {
        uint256 amount = 100e18;
        uint256 receiverBalanceBefore = DAI.balanceOf(receiver);

        vm.signAndAttachDelegation(relayerAddress, victimPkey);

        vm.startPrank(relayerAddress);
        relayer.send(victim, receiver, amount, address(DAI));
        vm.stopPrank();

        assertEq(DAI.balanceOf(receiver), receiverBalanceBefore + amount);
    }

    function test_cannotSendWithoutAuthorization() public {
        uint256 amount = 0.05 ether;

        // No delegation signed → should revert
        vm.expectRevert("Not the owner");

        // Relayer calls without victim’s delegation
        vm.startPrank(relayerAddress);
        relayer.send(victim, receiver, amount, address(0));
        vm.stopPrank();
    }

    function test_eventEmitted() public {
        uint256 amount = 0.02 ether;

        vm.signAndAttachDelegation(relayerAddress, victimPkey);

        vm.expectEmit(true, true, true, true);
        emit Relayer.TransactionSent(victim, receiver, amount, address(0));

        vm.startPrank(relayerAddress);
        relayer.send(victim, receiver, amount, address(0));
        vm.stopPrank();
    }
}
