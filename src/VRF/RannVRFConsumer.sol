// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {RannVRFCoordinator} from "./RannVRFCoordinator.sol";

/**
 * @title RannVRFConsumer
 * @author Rann Protocol
 * @notice Abstract contract for consuming VRF randomness with optimized patterns
 * @dev Provides helper functions for synchronous and asynchronous randomness consumption
 *
 * USAGE PATTERNS:
 * 1. Fast Path (Synchronous): Use _getInstantRandom() for immediate results
 * 2. Batch Path: Use _getBatchRandom(count) for multiple random numbers
 * 3. Request-Fulfill: Use _requestRandom() + _fulfillRandom() for guaranteed randomness
 *
 * OPTIMIZATION FEATURES:
 * - Automatic caching of random numbers
 * - Batch generation for multiple calls
 * - Gas-efficient storage patterns
 * - Fallback mechanisms for reliability
 */

abstract contract RannVRFConsumer {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/

    error RannVRF__RandomnessNotAvailable();
    error RannVRF__InvalidVRFCoordinator();

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/

    RannVRFCoordinator internal immutable i_vrfCoordinator;

    // Request tracking
    mapping(uint256 => bool) internal s_pendingRequests;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address vrfCoordinator) {
        if (vrfCoordinator == address(0)) {
            revert RannVRF__InvalidVRFCoordinator();
        }
        i_vrfCoordinator = RannVRFCoordinator(vrfCoordinator);
    }

    /*//////////////////////////////////////////////////////////////
                         RANDOMNESS HELPERS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get instant randomness (synchronous, 1-2 second latency)
     * @return Random uint256 value
     * @dev Uses blockhash-based generation, gas-optimized
     */
    function _getInstantRandom() internal view returns (uint256) {
        uint256 randomness = i_vrfCoordinator.getInstantRandomness();

        if (randomness == 0) {
            // Fallback: use blockhash directly (less secure but functional)
            randomness = uint256(keccak256(abi.encodePacked(
                blockhash(block.number - 1),
                block.timestamp,
                msg.sender,
                address(this)
            )));
        }

        return randomness;
    }

    /**
     * @notice Get multiple random numbers in single call (batch optimization)
     * @param count Number of random values needed (max 20)
     * @return Array of random uint256 values
     * @dev More gas-efficient than multiple _getInstantRandom() calls
     */
    function _getBatchRandom(uint8 count) internal view returns (uint256[] memory) {
        uint256[] memory randomNumbers = i_vrfCoordinator.getBatchRandomness(count);

        // Fallback if VRF unavailable
        for (uint8 i = 0; i < count; i++) {
            if (randomNumbers[i] == 0) {
                randomNumbers[i] = uint256(keccak256(abi.encodePacked(
                    blockhash(block.number - 1),
                    block.timestamp,
                    msg.sender,
                    address(this),
                    i
                )));
            }
        }

        return randomNumbers;
    }

    /**
     * @notice Request verifiable randomness (async pattern)
     * @param secret Secret value for commitment
     * @return requestId Identifier for retrieving randomness later
     * @dev Two-phase: request now, fulfill later with _getFulfilledRandom()
     */
    function _requestRandom(bytes32 secret) internal returns (uint256 requestId) {
        bytes32 commitment = keccak256(abi.encodePacked(
            secret,
            block.number,
            address(this)
        ));

        requestId = i_vrfCoordinator.requestRandomness(commitment);
        s_pendingRequests[requestId] = true;
    }

    /**
     * @notice Get randomness from fulfilled request
     * @param requestId The request ID to retrieve
     * @return Random uint256 value (reverts if not fulfilled)
     */
    function _getFulfilledRandom(uint256 requestId) internal view returns (uint256) {
        require(s_pendingRequests[requestId], "Request not found");

        uint256 randomness = i_vrfCoordinator.getRandomness(requestId);

        if (randomness == 0) {
            revert RannVRF__RandomnessNotAvailable();
        }

        return randomness;
    }

    /**
     * @notice Check if randomness request is ready
     * @param requestId The request ID to check
     * @return True if fulfilled and ready to use
     */
    function _isRandomReady(uint256 requestId) internal view returns (bool) {
        return i_vrfCoordinator.isRequestFulfilled(requestId);
    }

    /*//////////////////////////////////////////////////////////////
                    OPTIMIZED HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get random number in range [0, max)
     * @param max Upper bound (exclusive)
     * @return Random number in range
     * @dev Optimized modulo operation with instant randomness
     */
    function _getRandomInRange(uint256 max) internal view returns (uint256) {
        require(max > 0, "Max must be positive");
        return _getInstantRandom() % max;
    }

    /**
     * @notice Get random number in range [min, max]
     * @param min Lower bound (inclusive)
     * @param max Upper bound (inclusive)
     * @return Random number in range
     */
    function _getRandomBetween(uint256 min, uint256 max) internal view returns (uint256) {
        require(max >= min, "Invalid range");
        if (max == min) return min;

        uint256 range = max - min + 1;
        return min + (_getInstantRandom() % range);
    }

    /**
     * @notice Get random percentage (0-9999, basis points)
     * @return Random percentage value
     * @dev Optimized for success rate calculations like in Kurukshetra
     */
    function _getRandomPercentage() internal view returns (uint256) {
        return _getInstantRandom() % 10000;
    }

    /**
     * @notice Get random boolean with 50/50 probability
     * @return True or false
     */
    function _getRandomBool() internal view returns (bool) {
        return (_getInstantRandom() % 2) == 1;
    }

    /**
     * @notice Get N unique random numbers in range [0, max)
     * @param count Number of unique values needed
     * @param max Upper bound (exclusive)
     * @return Array of unique random numbers
     * @dev O(n) algorithm, much faster than nested loops
     */
    function _getUniqueRandoms(uint8 count, uint256 max)
        internal
        view
        returns (uint256[] memory)
    {
        require(count <= max, "Count exceeds range");
        require(count <= 20, "Batch too large");

        uint256[] memory results = new uint256[](count);
        uint256[] memory available = new uint256[](max);

        // Initialize available pool
        for (uint256 i = 0; i < max; i++) {
            available[i] = i;
        }

        // Fisher-Yates shuffle for first N elements
        uint256[] memory randoms = _getBatchRandom(count);
        uint256 remainingSize = max;

        for (uint8 i = 0; i < count; i++) {
            uint256 index = randoms[i] % remainingSize;
            results[i] = available[index];

            // Swap with last element and reduce size
            available[index] = available[remainingSize - 1];
            remainingSize--;
        }

        return results;
    }

    /*//////////////////////////////////////////////////////////////
                          VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /**
     * @notice Get VRF coordinator address
     * @return Address of the VRF coordinator contract
     */
    function getVRFCoordinator() external view returns (address) {
        return address(i_vrfCoordinator);
    }
}
