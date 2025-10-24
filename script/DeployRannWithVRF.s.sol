// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RannVRFCoordinator} from "../src/VRF/RannVRFCoordinator.sol";
import {GurukulOptimized} from "../src/Gurukul/GurukulOptimized.sol";
import {KurukshetraOptimized} from "../src/Kurukshetra/KurukshetraOptimized.sol";
import {RannToken} from "../src/RannToken.sol";
import {YodhaNFT} from "../src/Chaavani/YodhaNFT.sol";
import {Bazaar} from "../src/Bazaar/Bazaar.sol";
import {KurukshetraFactoryOptimized} from "../src/Kurukshetra/KurukshetraFactoryOptimized.sol";
import {IYodhaNFT} from "../src/Interfaces/IYodhaNFT.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

/**
 * @title DeployRannWithVRF
 * @notice Deploy complete Rann Protocol with custom VRF integration
 */
contract DeployRannWithVRF is Script {
    // Deployed contracts
    RannVRFCoordinator public vrfCoordinator;
    RannToken public rannToken;
    YodhaNFT public yodhaNFT;
    GurukulOptimized public gurukul;
    Bazaar public bazaar;
    KurukshetraFactoryOptimized public kurukshetraFactory;

    // Config
    HelperConfig public helperConfig;
    address public dao;
    address public gameMasterPublicKey;

    function run() external returns (
        RannVRFCoordinator,
        RannToken,
        YodhaNFT,
        GurukulOptimized,
        Bazaar,
        KurukshetraFactoryOptimized
    ) {
        console.log("========================================");
        console.log("Deploying Rann Protocol with Custom VRF");
        console.log("========================================");
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", msg.sender);
        console.log("");

        // Get configuration
        helperConfig = new HelperConfig();
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();

        dao = msg.sender; // Deployer acts as DAO initially
        gameMasterPublicKey = config.gameMasterPublicKey;

        console.log("Configuration:");
        console.log("  DAO:", dao);
        console.log("  Game Master:", gameMasterPublicKey);
        console.log("");

        vm.startBroadcast();

        // 1. Deploy VRF Coordinator
        console.log("1. Deploying RannVRFCoordinator...");
        vrfCoordinator = new RannVRFCoordinator();
        console.log("   Address:", address(vrfCoordinator));
        console.log("");

        // 2. Deploy RannToken
        console.log("2. Deploying RannToken...");
        rannToken = new RannToken();
        console.log("   Address:", address(rannToken));
        console.log("");

        // 3. Deploy YodhaNFT
        console.log("3. Deploying YodhaNFT...");
        yodhaNFT = new YodhaNFT(dao, gameMasterPublicKey);
        console.log("   Address:", address(yodhaNFT));
        console.log("");

        // 4. Deploy GurukulOptimized with VRF
        console.log("4. Deploying GurukulOptimized...");

        uint256[] memory questionsToOptions = new uint256[](10);
        for (uint256 i = 0; i < 10; i++) {
            questionsToOptions[i] = 4; // 4 options per question
        }

        gurukul = new GurukulOptimized(
            address(vrfCoordinator),
            dao,
            address(yodhaNFT),
            10, // initialNumberOfQuestions
            questionsToOptions,
            "QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX", // placeholder IPFS CID
            gameMasterPublicKey // NEAR AI public key
        );
        console.log("   Address:", address(gurukul));
        console.log("");

        // 5. Set Gurukul in YodhaNFT
        console.log("5. Configuring YodhaNFT with Gurukul...");
        yodhaNFT.setGurukul(address(gurukul));
        console.log("   Gurukul set");
        console.log("");

        // 6. Deploy Bazaar
        console.log("6. Deploying Bazaar...");
        bazaar = new Bazaar(address(yodhaNFT), address(rannToken));
        console.log("   Address:", address(bazaar));
        console.log("");

        // 7. Deploy KurukshetraFactoryOptimized
        console.log("7. Deploying KurukshetraFactoryOptimized...");
        kurukshetraFactory = new KurukshetraFactoryOptimized(
            address(rannToken),
            address(yodhaNFT),
            gameMasterPublicKey,
            address(vrfCoordinator) // VRF coordinator for optimized battles
        );
        console.log("   Address:", address(kurukshetraFactory));
        console.log("");

        // 8. Set KurukshetraFactory in YodhaNFT
        console.log("8. Configuring YodhaNFT with KurukshetraFactory...");
        yodhaNFT.setKurukshetraFactory(address(kurukshetraFactory));
        console.log("   Factory set");
        console.log("");

        // 9. Configure VRF access control
        console.log("9. Configuring VRF access control...");
        vrfCoordinator.addConsumer(address(gurukul));
        console.log("   Gurukul authorized as consumer");
        // Note: Kurukshetra instances will be added when created by factory
        console.log("");

        vm.stopBroadcast();

        // Print deployment summary
        printDeploymentSummary();

        return (vrfCoordinator, rannToken, yodhaNFT, gurukul, bazaar, kurukshetraFactory);
    }

    function printDeploymentSummary() internal view {
        console.log("========================================");
        console.log("Deployment Summary");
        console.log("========================================");
        console.log("");
        console.log("Core Contracts:");
        console.log("  RannVRFCoordinator:", address(vrfCoordinator));
        console.log("  RannToken:", address(rannToken));
        console.log("  YodhaNFT:", address(yodhaNFT));
        console.log("  GurukulOptimized:", address(gurukul));
        console.log("  Bazaar:", address(bazaar));
        console.log("  KurukshetraFactory:", address(kurukshetraFactory));
        console.log("");
        console.log("Configuration:");
        console.log("  DAO:", dao);
        console.log("  Game Master:", gameMasterPublicKey);
        console.log("");
        console.log("VRF Access Control:");
        console.log("  Authorized Consumers:");
        console.log("    - Gurukul:", vrfCoordinator.isConsumer(address(gurukul)));
        console.log("  Authorized Fulfillers:");
        console.log("    - Deployer:", vrfCoordinator.isFulfiller(msg.sender));
        console.log("");
        console.log("Next Steps:");
        console.log("  1. Update frontend with contract addresses");
        console.log("  2. Create first Kurukshetra arena via factory");
        console.log("  3. Upload questions to IPFS and update Gurukul");
        console.log("  4. Test VRF randomness in Gurukul (training)");
        console.log("  5. Test VRF randomness in Kurukshetra (battles)");
        console.log("========================================");
    }
}
