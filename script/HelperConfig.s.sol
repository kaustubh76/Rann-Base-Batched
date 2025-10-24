// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "../lib/forge-std/src/Script.sol";

contract HelperConfig is Script {
    error HelperConfig__ChainIdNotSupported();

    struct NetworkConfig {
        address gameMasterPublicKey;
        address cadenceArch;
        uint256 initialNumberOfQuestions;
        uint256[] initialQuestionsToOptions;
        uint256 costToInfluence;
        uint256 costToDefluence;
        uint256 betAmount;
        string initialIpfsCid;
    }

    address public constant GAME_MASTER_PUBLIC_KEY = 0x5c6E63E3681D4EB7dEeaA0B4e6C552C636d28263; // need to set this to the actual game master public key once the backend is ready
    uint256 public constant INITIAL_NUMBER_OF_QUESTIONS = 5;
    // VRF Coordinator deployed on Base Sepolia
    address public constant CADENCE_ARCH = 0x2EE0A35b1a39f17a57A034203617f01E81F62020; // RannVRFCoordinator
    uint256[] public s_initialQuestionsToOptions;
    uint256 public constant COST_TO_INFLUENCE = 0.00001 ether;
    uint256 public constant COST_TO_DEFLUENCE = 0.0001 ether;
    uint256 public constant BET_AMOUNT = 0.001 ether;
    string public constant INITIAL_IPFS_CID = "INITIAL_IPFS_CID"; // need to set this to the actual IPFS CID once the backend is ready

    NetworkConfig public activeNetworkConfig;

    constructor() {
        s_initialQuestionsToOptions = [4, 4, 4, 4, 4];

        if (block.chainid == 84532) {
            // Base Sepolia
            activeNetworkConfig = getBaseSepoliaNetworkConfig();
        } else if (block.chainid == 8453) {
            // Base Mainnet
            activeNetworkConfig = getBaseMainnetNetworkConfig();
        } else if (block.chainid == 747) {
            // Flow Testnet (legacy support)
            activeNetworkConfig = getFlowTestnetNetworkConfig();
        } else if (block.chainid == 545) {
            // Flow Mainnet (legacy support)
            activeNetworkConfig = getFlowMainnetNetworkConfig();
        } else {
            revert HelperConfig__ChainIdNotSupported();
        }
    }

    /**
     *  @notice Returns the active network configuration.
     */
    function getConfig() external view returns (NetworkConfig memory) {
        return activeNetworkConfig;
    }

    /**
     *  @notice Returns the network configuration for Flow Testnet.
     */
    function getFlowTestnetNetworkConfig() internal view returns (NetworkConfig memory _flowTestnetNetworkConfig) {
        _flowTestnetNetworkConfig = NetworkConfig({
            gameMasterPublicKey: GAME_MASTER_PUBLIC_KEY,
            cadenceArch: CADENCE_ARCH,
            initialNumberOfQuestions: INITIAL_NUMBER_OF_QUESTIONS,
            initialQuestionsToOptions: s_initialQuestionsToOptions,
            costToInfluence: COST_TO_INFLUENCE,
            costToDefluence: COST_TO_DEFLUENCE,
            betAmount: BET_AMOUNT,
            initialIpfsCid: INITIAL_IPFS_CID
        });
    }

    /**
     *   @notice Returns the network configuration for Flow Mainnet.
     */
    function getFlowMainnetNetworkConfig() internal view returns (NetworkConfig memory _sepoliaNotworkConfig) {
        _sepoliaNotworkConfig = NetworkConfig({
            gameMasterPublicKey: GAME_MASTER_PUBLIC_KEY,
            cadenceArch: CADENCE_ARCH,
            initialNumberOfQuestions: INITIAL_NUMBER_OF_QUESTIONS,
            initialQuestionsToOptions: s_initialQuestionsToOptions,
            costToInfluence: COST_TO_INFLUENCE,
            costToDefluence: COST_TO_DEFLUENCE,
            betAmount: BET_AMOUNT,
            initialIpfsCid: INITIAL_IPFS_CID
        });
    }

    /**
     *  @notice Returns the network configuration for Base Sepolia.
     */
    function getBaseSepoliaNetworkConfig() internal view returns (NetworkConfig memory _baseSepoliaNetworkConfig) {
        _baseSepoliaNetworkConfig = NetworkConfig({
            gameMasterPublicKey: GAME_MASTER_PUBLIC_KEY,
            cadenceArch: CADENCE_ARCH, // Will be used for VRF later, keeping for now
            initialNumberOfQuestions: INITIAL_NUMBER_OF_QUESTIONS,
            initialQuestionsToOptions: s_initialQuestionsToOptions,
            costToInfluence: COST_TO_INFLUENCE,
            costToDefluence: COST_TO_DEFLUENCE,
            betAmount: BET_AMOUNT,
            initialIpfsCid: INITIAL_IPFS_CID
        });
    }

    /**
     *  @notice Returns the network configuration for Base Mainnet.
     */
    function getBaseMainnetNetworkConfig() internal view returns (NetworkConfig memory _baseMainnetNetworkConfig) {
        _baseMainnetNetworkConfig = NetworkConfig({
            gameMasterPublicKey: GAME_MASTER_PUBLIC_KEY,
            cadenceArch: CADENCE_ARCH, // Will be used for VRF later, keeping for now
            initialNumberOfQuestions: INITIAL_NUMBER_OF_QUESTIONS,
            initialQuestionsToOptions: s_initialQuestionsToOptions,
            costToInfluence: COST_TO_INFLUENCE,
            costToDefluence: COST_TO_DEFLUENCE,
            betAmount: BET_AMOUNT,
            initialIpfsCid: INITIAL_IPFS_CID
        });
    }
}
