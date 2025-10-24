// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RannVRFCoordinator} from "../src/VRF/RannVRFCoordinator.sol";

/**
 * @title DeployVRFSimple
 * @notice Simple deployment script for RannVRFCoordinator only
 * @dev Deploy with: forge script script/DeployVRFSimple.s.sol:DeployVRFSimple --rpc-url $RPC_URL --broadcast --verify
 */
contract DeployVRFSimple is Script {
    function run() external returns (RannVRFCoordinator) {
        console.log("========================================");
        console.log("Deploying RannVRFCoordinator");
        console.log("========================================");
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", msg.sender);
        console.log("");

        vm.startBroadcast();

        RannVRFCoordinator coordinator = new RannVRFCoordinator();

        vm.stopBroadcast();

        console.log("========================================");
        console.log("Deployment Complete!");
        console.log("========================================");
        console.log("RannVRFCoordinator:", address(coordinator));
        console.log("Owner:", msg.sender);
        console.log("");
        console.log("Next Steps:");
        console.log("1. Add consumers: coordinator.addConsumer(address)");
        console.log("2. Add fulfillers: coordinator.addFulfiller(address)");
        console.log("3. Test randomness generation");
        console.log("========================================");

        return coordinator;
    }
}
