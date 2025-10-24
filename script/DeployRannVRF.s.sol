// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {RannVRFCoordinator} from "../src/VRF/RannVRFCoordinator.sol";
import {GurukulOptimized} from "../src/Gurukul/GurukulOptimized.sol";
import {KurukshetraOptimized} from "../src/Kurukshetra/KurukshetraOptimized.sol";
import {IYodhaNFT} from "../src/Interfaces/IYodhaNFT.sol";

/**
 * @title DeployRannVRF
 * @notice Deployment script for Rann Protocol custom VRF system
 * @dev Deploys:
 *      1. RannVRFCoordinator (core VRF contract)
 *      2. GurukulOptimized (training with custom VRF)
 *      3. KurukshetraOptimized (battle with custom VRF)
 *
 * USAGE:
 * Deploy to testnet:
 *   forge script script/DeployRannVRF.s.sol:DeployRannVRF --rpc-url $BASE_SEPOLIA_RPC_URL --broadcast --verify
 *
 * Deploy to mainnet:
 *   forge script script/DeployRannVRF.s.sol:DeployRannVRF --rpc-url $BASE_MAINNET_RPC_URL --broadcast --verify
 */
contract DeployRannVRF is Script {
    // Configuration structs
    struct NetworkConfig {
        address rannToken;
        address yodhaNFT;
        address dao;
        address nearAiPublicKey;
        address kurukshetraFactory;
    }

    struct GurukulConfig {
        uint256 initialNumberOfQuestions;
        uint256[] initialQuestionsToOptions;
        string initialIpfsCID;
    }

    struct KurukshetraConfig {
        IYodhaNFT.Ranking rankCategory;
        uint256 betAmount;
        uint256 costToInfluence;
        uint256 costToDefluence;
    }

    // Deployment tracking
    RannVRFCoordinator public vrfCoordinator;
    GurukulOptimized public gurukul;
    KurukshetraOptimized public kurukshetra;

    function run() external returns (RannVRFCoordinator, GurukulOptimized, KurukshetraOptimized) {
        // Load network configuration
        NetworkConfig memory config = getNetworkConfig();

        console.log("========================================");
        console.log("Deploying Rann VRF System");
        console.log("========================================");
        console.log("Network:", block.chainid);
        console.log("Deployer:", msg.sender);
        console.log("");

        vm.startBroadcast();

        // Step 1: Deploy VRF Coordinator
        console.log("1. Deploying RannVRFCoordinator...");
        vrfCoordinator = new RannVRFCoordinator();
        console.log("   Deployed at:", address(vrfCoordinator));
        console.log("");

        // Step 2: Deploy Gurukul with VRF
        console.log("2. Deploying GurukulOptimized...");
        GurukulConfig memory gurukulConfig = getGurukulConfig();

        gurukul = new GurukulOptimized(
            address(vrfCoordinator),
            config.dao,
            config.yodhaNFT,
            gurukulConfig.initialNumberOfQuestions,
            gurukulConfig.initialQuestionsToOptions,
            gurukulConfig.initialIpfsCID,
            config.nearAiPublicKey
        );
        console.log("   Deployed at:", address(gurukul));
        console.log("");

        // Step 3: Deploy Kurukshetra with VRF
        console.log("3. Deploying KurukshetraOptimized...");
        KurukshetraConfig memory kurukshetraConfig = getKurukshetraConfig();

        kurukshetra = new KurukshetraOptimized(
            address(vrfCoordinator),
            config.rannToken,
            config.yodhaNFT,
            config.nearAiPublicKey,
            kurukshetraConfig.rankCategory,
            kurukshetraConfig.betAmount,
            kurukshetraConfig.costToInfluence,
            kurukshetraConfig.costToDefluence,
            config.kurukshetraFactory
        );
        console.log("   Deployed at:", address(kurukshetra));
        console.log("");

        // Step 4: Configure VRF access control
        console.log("4. Configuring VRF access control...");
        vrfCoordinator.addConsumer(address(gurukul));
        console.log("   Added Gurukul as VRF consumer");

        vrfCoordinator.addConsumer(address(kurukshetra));
        console.log("   Added Kurukshetra as VRF consumer");
        console.log("");

        vm.stopBroadcast();

        // Print deployment summary
        printDeploymentSummary(config);

        return (vrfCoordinator, gurukul, kurukshetra);
    }

    /*//////////////////////////////////////////////////////////////
                        CONFIGURATION HELPERS
    //////////////////////////////////////////////////////////////*/

    function getNetworkConfig() public view returns (NetworkConfig memory) {
        if (block.chainid == 84532) {
            // Base Sepolia
            return NetworkConfig({
                rannToken: 0x0000000000000000000000000000000000000000, // TODO: Update
                yodhaNFT: 0x0000000000000000000000000000000000000000, // TODO: Update
                dao: msg.sender, // Deployer as DAO initially
                nearAiPublicKey: 0x0000000000000000000000000000000000000000, // TODO: Update
                kurukshetraFactory: 0x0000000000000000000000000000000000000000 // TODO: Update
            });
        } else if (block.chainid == 8453) {
            // Base Mainnet
            return NetworkConfig({
                rannToken: 0x0000000000000000000000000000000000000000, // TODO: Update
                yodhaNFT: 0x0000000000000000000000000000000000000000, // TODO: Update
                dao: 0x0000000000000000000000000000000000000000, // TODO: Update
                nearAiPublicKey: 0x0000000000000000000000000000000000000000, // TODO: Update
                kurukshetraFactory: 0x0000000000000000000000000000000000000000 // TODO: Update
            });
        } else {
            // Anvil/Local testnet
            return NetworkConfig({
                rannToken: address(1),
                yodhaNFT: address(2),
                dao: msg.sender,
                nearAiPublicKey: msg.sender,
                kurukshetraFactory: address(3)
            });
        }
    }

    function getGurukulConfig() public pure returns (GurukulConfig memory) {
        uint256[] memory questionsToOptions = new uint256[](10);
        for (uint256 i = 0; i < 10; i++) {
            questionsToOptions[i] = 4; // 4 options per question
        }

        return GurukulConfig({
            initialNumberOfQuestions: 10,
            initialQuestionsToOptions: questionsToOptions,
            initialIpfsCID: "QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" // TODO: Update
        });
    }

    function getKurukshetraConfig() public pure returns (KurukshetraConfig memory) {
        return KurukshetraConfig({
            rankCategory: IYodhaNFT.Ranking.BRONZE,
            betAmount: 100 ether, // 100 RANN tokens
            costToInfluence: 10 ether, // 10 RANN tokens
            costToDefluence: 50 ether // 50 RANN tokens
        });
    }

    /*//////////////////////////////////////////////////////////////
                          HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function printDeploymentSummary(NetworkConfig memory config) internal view {
        console.log("========================================");
        console.log("Deployment Summary");
        console.log("========================================");
        console.log("");

        console.log("Core Contracts:");
        console.log("  RannVRFCoordinator:", address(vrfCoordinator));
        console.log("  GurukulOptimized:", address(gurukul));
        console.log("  KurukshetraOptimized:", address(kurukshetra));
        console.log("");

        console.log("Network Configuration:");
        console.log("  Rann Token:", config.rannToken);
        console.log("  Yodha NFT:", config.yodhaNFT);
        console.log("  DAO:", config.dao);
        console.log("  NEAR AI Public Key:", config.nearAiPublicKey);
        console.log("  Kurukshetra Factory:", config.kurukshetraFactory);
        console.log("");

        console.log("VRF Access Control:");
        console.log("  Authorized Consumers:");
        console.log("    - Gurukul:", vrfCoordinator.isConsumer(address(gurukul)));
        console.log("    - Kurukshetra:", vrfCoordinator.isConsumer(address(kurukshetra)));
        console.log("");

        console.log("Next Steps:");
        console.log("  1. Update contract addresses in frontend");
        console.log("  2. Configure NEAR AI fulfiller:");
        console.log("     vrfCoordinator.addFulfiller(<fulfiller_address>)");
        console.log("  3. Test VRF randomness generation");
        console.log("  4. Initialize first Kurukshetra game");
        console.log("========================================");
    }
}

/**
 * @title DeployVRFOnly
 * @notice Deploy only the VRF Coordinator (for testing or standalone use)
 */
contract DeployVRFOnly is Script {
    function run() external returns (RannVRFCoordinator) {
        console.log("Deploying RannVRFCoordinator...");

        vm.startBroadcast();
        RannVRFCoordinator coordinator = new RannVRFCoordinator();
        vm.stopBroadcast();

        console.log("Deployed at:", address(coordinator));
        console.log("Owner:", msg.sender);

        return coordinator;
    }
}

/**
 * @title ConfigureVRFFulfiller
 * @notice Script to add VRF fulfiller addresses after deployment
 */
contract ConfigureVRFFulfiller is Script {
    function run(address vrfCoordinator, address fulfiller) external {
        console.log("Configuring VRF Fulfiller...");
        console.log("VRF Coordinator:", vrfCoordinator);
        console.log("Fulfiller:", fulfiller);

        vm.startBroadcast();
        RannVRFCoordinator(vrfCoordinator).addFulfiller(fulfiller);
        vm.stopBroadcast();

        console.log("Fulfiller added successfully");
    }
}
