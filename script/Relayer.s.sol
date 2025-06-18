// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import "../src/smart-wallet/Relayer.sol";

contract DeployScript is Script {
    function run() external {
        uint256 OWNER_PK = vm.envUint("OWNER");
        uint256 HOTWALLET_ADMIN_PK = vm.envUint("HOTWALLET_ADMIN");

        address HOTWALLET_ADMIN = vm.addr(HOTWALLET_ADMIN_PK);

        // Start broadcasting transactions using the Owner private key
        vm.startBroadcast(OWNER_PK);

        Relayer deployer = new Relayer(HOTWALLET_ADMIN);

        console.log("Deployed Relayer at:", address(deployer));
        vm.stopBroadcast();
    }
}
