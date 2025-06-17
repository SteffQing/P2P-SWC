// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import "../src/smart-wallet/Relayer.sol";

contract DeployScript is Script {
    function run() external {
        uint256 OWNER_PK = vm.envUint("OWNER");

        // Start broadcasting transactions using the Owner private key
        vm.startBroadcast(OWNER_PK);

        Relayer deployer = new Relayer(
            0xF4EEDe95288A33DA06B4Babe2D5ED7CE7ef6A279
        );

        console.log("Deployed Relayer at:", address(deployer));
        vm.stopBroadcast();
    }
}
