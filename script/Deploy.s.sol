// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "forge-std/Vm.sol";
import "../src/deployer/WalletDeployer.sol";

contract DeployScript is Script {
    function run() external {
        uint256 DEPLOYER_ADMIN_PK = vm.envUint("DEPLOYER_ADMIN");
        uint256 SMARTWALLET_ADMIN_PK = vm.envUint("SMARTWALLET_ADMIN");
        uint256 HOTWALLET_ADMIN_PK = vm.envUint("HOTWALLET_ADMIN");
        uint256 OWNER_PK = vm.envUint("OWNER");

        address SMARTWALLET_ADMIN = vm.addr(SMARTWALLET_ADMIN_PK);
        address HOTWALLET_ADMIN = vm.addr(HOTWALLET_ADMIN_PK);
        address DEPLOYER_ADMIN = vm.addr(DEPLOYER_ADMIN_PK);

        // Start broadcasting transactions using the Owner private key
        vm.startBroadcast(OWNER_PK);

        WAAS_Deployer deployer = new WAAS_Deployer(
            SMARTWALLET_ADMIN, // SmartWalletAdmin
            HOTWALLET_ADMIN, // HotWalletAdmin
            DEPLOYER_ADMIN // DeployerAdmin
        );

        console.log("Deployed WAAS_Deployer at:", address(deployer));
        // console.log("SMARTWALLET_ADMIN address:", SMARTWALLET_ADMIN);
        // console.log("HOTWALLET_ADMIN address:", HOTWALLET_ADMIN);
        // console.log("DEPLOYER_ADMIN address:", DEPLOYER_ADMIN);
        // console.log("OWNER address:", vm.addr(OWNER_PK));

        vm.stopBroadcast();

        // vm.startBroadcast(DEPLOYER_ADMIN_PK);

        // vm.recordLogs();
        // deployer.deployWallet();

        // Vm.Log[] memory logs = vm.getRecordedLogs();

        // for (uint256 i = 0; i < logs.length; i++) {
        //     if (logs[i].topics[0] == keccak256("WalletCreated(address)")) {
        //         address walletAddress = address(
        //             uint160(uint256(logs[i].topics[1]))
        //         );
        //         console.log("New Smart Wallet deployed at:", walletAddress);
        //     }
        // }

        // vm.stopBroadcast();
    }
}
