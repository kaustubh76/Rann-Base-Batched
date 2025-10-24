// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {RannVRFCoordinator} from "../src/VRF/RannVRFCoordinator.sol";
import {RannVRFConsumer} from "../src/VRF/RannVRFConsumer.sol";

/**
 * @title RannVRFTest
 * @notice Comprehensive tests for custom VRF implementation
 * @dev Tests cover:
 *      - Randomness request/fulfillment
 *      - Instant randomness (fast path)
 *      - Batch randomness generation
 *      - Access control
 *      - Performance characteristics
 */
contract RannVRFTest is Test {
    RannVRFCoordinator public coordinator;
    MockVRFConsumer public consumer;

    address public owner = address(1);
    address public fulfiller = address(2);
    address public unauthorizedUser = address(3);

    bytes32 public constant TEST_SECRET = keccak256("test_secret");

    function setUp() public {
        vm.startPrank(owner);

        // Deploy coordinator
        coordinator = new RannVRFCoordinator();

        // Deploy consumer
        consumer = new MockVRFConsumer(address(coordinator));

        // Configure access control
        coordinator.addFulfiller(fulfiller);
        coordinator.addConsumer(address(consumer));

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        BASIC FUNCTIONALITY TESTS
    //////////////////////////////////////////////////////////////*/

    function testDeployment() public {
        assertEq(coordinator.isFulfiller(owner), true, "Owner should be fulfiller");
        assertEq(coordinator.isConsumer(address(consumer)), true, "Consumer should be authorized");
    }

    function testRequestRandomness() public {
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        uint256 requestId = coordinator.requestRandomness(commitment);

        assertEq(requestId, 1, "First request should have ID 1");
        assertEq(coordinator.isRequestFulfilled(requestId), false, "Request should not be fulfilled yet");

        vm.stopPrank();
    }

    function testFulfillRandomness() public {
        // Request
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        uint256 requestId = coordinator.requestRandomness(commitment);
        vm.stopPrank();

        // Advance block for confirmations
        vm.roll(block.number + 2);

        // Fulfill
        vm.prank(fulfiller);
        coordinator.fulfillRandomness(requestId, TEST_SECRET);

        // Verify
        assertEq(coordinator.isRequestFulfilled(requestId), true, "Request should be fulfilled");

        uint256 randomness = coordinator.getRandomness(requestId);
        assertGt(randomness, 0, "Randomness should be non-zero");
    }

    function testInstantRandomness() public {
        vm.roll(block.number + 1);

        uint256 random = coordinator.getInstantRandomness();

        // Note: May return 0 if blockhash not available in test environment
        console.log("Instant randomness:", random);
    }

    function testBatchRandomness() public {
        vm.roll(block.number + 1);

        uint256[] memory randoms = coordinator.getBatchRandomness(5);

        assertEq(randoms.length, 5, "Should return 5 random numbers");

        // Check uniqueness (with high probability)
        for (uint i = 0; i < 5; i++) {
            for (uint j = i + 1; j < 5; j++) {
                assertTrue(randoms[i] != randoms[j], "Random numbers should be unique");
            }
        }
    }

    /*//////////////////////////////////////////////////////////////
                        ACCESS CONTROL TESTS
    //////////////////////////////////////////////////////////////*/

    function testRevertUnauthorizedConsumer() public {
        vm.prank(unauthorizedUser);

        bytes32 commitment = keccak256("test");

        vm.expectRevert("Unauthorized consumer");
        coordinator.requestRandomness(commitment);
    }

    function testRevertUnauthorizedFulfiller() public {
        // Create valid request first
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        uint256 requestId = coordinator.requestRandomness(commitment);
        vm.stopPrank();

        vm.roll(block.number + 2);

        // Try to fulfill with unauthorized account
        vm.prank(unauthorizedUser);

        vm.expectRevert(RannVRFCoordinator.RannVRF__UnauthorizedFulfiller.selector);
        coordinator.fulfillRandomness(requestId, TEST_SECRET);
    }

    function testAddRemoveFulfiller() public {
        address newFulfiller = address(4);

        vm.startPrank(owner);

        coordinator.addFulfiller(newFulfiller);
        assertEq(coordinator.isFulfiller(newFulfiller), true, "Fulfiller should be added");

        coordinator.removeFulfiller(newFulfiller);
        assertEq(coordinator.isFulfiller(newFulfiller), false, "Fulfiller should be removed");

        vm.stopPrank();
    }

    function testAddRemoveConsumer() public {
        address newConsumer = address(5);

        vm.startPrank(owner);

        coordinator.addConsumer(newConsumer);
        assertEq(coordinator.isConsumer(newConsumer), true, "Consumer should be added");

        coordinator.removeConsumer(newConsumer);
        assertEq(coordinator.isConsumer(newConsumer), false, "Consumer should be removed");

        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                        SECURITY TESTS
    //////////////////////////////////////////////////////////////*/

    function testRevertInvalidCommitment() public {
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        uint256 requestId = coordinator.requestRandomness(commitment);
        vm.stopPrank();

        vm.roll(block.number + 2);

        // Try to fulfill with wrong secret
        bytes32 wrongSecret = keccak256("wrong_secret");

        vm.prank(fulfiller);
        vm.expectRevert(RannVRFCoordinator.RannVRF__InvalidCommitment.selector);
        coordinator.fulfillRandomness(requestId, wrongSecret);
    }

    function testRevertInsufficientConfirmations() public {
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        uint256 requestId = coordinator.requestRandomness(commitment);
        vm.stopPrank();

        // Try to fulfill immediately (no block advancement)
        vm.prank(fulfiller);
        vm.expectRevert(RannVRFCoordinator.RannVRF__InsufficientBlockConfirmations.selector);
        coordinator.fulfillRandomness(requestId, TEST_SECRET);
    }

    function testRevertCommitmentTooOld() public {
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        uint256 requestId = coordinator.requestRandomness(commitment);
        vm.stopPrank();

        // Advance past MAX_COMMITMENT_AGE (256 blocks)
        vm.roll(block.number + 257);

        vm.prank(fulfiller);
        vm.expectRevert(RannVRFCoordinator.RannVRF__CommitmentTooOld.selector);
        coordinator.fulfillRandomness(requestId, TEST_SECRET);
    }

    /*//////////////////////////////////////////////////////////////
                        PERFORMANCE TESTS
    //////////////////////////////////////////////////////////////*/

    function testBatchFulfillment() public {
        uint256 batchSize = 10;
        uint256[] memory requestIds = new uint256[](batchSize);
        bytes32[] memory secrets = new bytes32[](batchSize);

        // Create multiple requests
        vm.startPrank(address(consumer));

        for (uint i = 0; i < batchSize; i++) {
            secrets[i] = keccak256(abi.encodePacked("secret", i));

            bytes32 commitment = keccak256(abi.encodePacked(
                secrets[i],
                block.number,
                address(consumer)
            ));

            requestIds[i] = coordinator.requestRandomness(commitment);
        }

        vm.stopPrank();

        vm.roll(block.number + 2);

        // Batch fulfill
        vm.prank(fulfiller);
        coordinator.batchFulfillRandomness(requestIds, secrets);

        // Verify all fulfilled
        for (uint i = 0; i < batchSize; i++) {
            assertTrue(coordinator.isRequestFulfilled(requestIds[i]), "Request should be fulfilled");
            assertGt(coordinator.getRandomness(requestIds[i]), 0, "Should have randomness");
        }
    }

    function testGasUsageComparison() public {
        // Test instant randomness gas cost
        uint256 gasBefore = gasleft();
        coordinator.getInstantRandomness();
        uint256 instantGas = gasBefore - gasleft();

        console.log("Instant randomness gas:", instantGas);

        // Test batch randomness gas cost
        gasBefore = gasleft();
        coordinator.getBatchRandomness(5);
        uint256 batchGas = gasBefore - gasleft();

        console.log("Batch randomness (5) gas:", batchGas);
        console.log("Gas per random number:", batchGas / 5);

        // Test request-fulfill pattern gas cost
        vm.startPrank(address(consumer));

        bytes32 commitment = keccak256(abi.encodePacked(
            TEST_SECRET,
            block.number,
            address(consumer)
        ));

        gasBefore = gasleft();
        uint256 requestId = coordinator.requestRandomness(commitment);
        uint256 requestGas = gasBefore - gasleft();

        vm.stopPrank();

        vm.roll(block.number + 2);

        vm.prank(fulfiller);
        gasBefore = gasleft();
        coordinator.fulfillRandomness(requestId, TEST_SECRET);
        uint256 fulfillGas = gasBefore - gasleft();

        console.log("Request gas:", requestGas);
        console.log("Fulfill gas:", fulfillGas);
        console.log("Total request-fulfill gas:", requestGas + fulfillGas);
    }

    /*//////////////////////////////////////////////////////////////
                        CONSUMER HELPER TESTS
    //////////////////////////////////////////////////////////////*/

    function testConsumerInstantRandom() public {
        vm.roll(block.number + 1);

        uint256 random = consumer.testGetInstantRandom();
        assertGt(random, 0, "Should return random number");
    }

    function testConsumerBatchRandom() public {
        vm.roll(block.number + 1);

        uint256[] memory randoms = consumer.testGetBatchRandom(5);

        assertEq(randoms.length, 5, "Should return 5 numbers");

        for (uint i = 0; i < 5; i++) {
            assertGt(randoms[i], 0, "Each random should be non-zero");
        }
    }

    function testConsumerRandomInRange() public {
        vm.roll(block.number + 1);

        uint256 max = 100;
        uint256 random = consumer.testGetRandomInRange(max);

        assertLt(random, max, "Random should be less than max");
    }

    function testConsumerRandomBetween() public {
        vm.roll(block.number + 1);

        uint256 min = 50;
        uint256 max = 150;
        uint256 random = consumer.testGetRandomBetween(min, max);

        assertGe(random, min, "Random should be >= min");
        assertLe(random, max, "Random should be <= max");
    }

    function testConsumerRandomPercentage() public {
        vm.roll(block.number + 1);

        uint256 percentage = consumer.testGetRandomPercentage();

        assertLt(percentage, 10000, "Percentage should be < 10000");
    }

    function testConsumerRandomBool() public {
        vm.roll(block.number + 1);

        // Test multiple times to check distribution
        uint256 trueCount = 0;
        uint256 iterations = 10;

        for (uint i = 0; i < iterations; i++) {
            vm.roll(block.number + i + 1);
            if (consumer.testGetRandomBool()) {
                trueCount++;
            }
        }

        console.log("True count out of", iterations, ":", trueCount);

        // We expect roughly 50/50, but won't be exact in small sample
        assertGt(trueCount, 0, "Should have some true values");
        assertLt(trueCount, iterations, "Should have some false values");
    }

    function testConsumerUniqueRandoms() public {
        vm.roll(block.number + 1);

        uint256[] memory randoms = consumer.testGetUniqueRandoms(5, 100);

        assertEq(randoms.length, 5, "Should return 5 numbers");

        // Check all unique
        for (uint i = 0; i < 5; i++) {
            for (uint j = i + 1; j < 5; j++) {
                assertTrue(randoms[i] != randoms[j], "Numbers should be unique");
            }
        }

        // Check all in range
        for (uint i = 0; i < 5; i++) {
            assertLt(randoms[i], 100, "Number should be in range");
        }
    }
}

/**
 * @title MockVRFConsumer
 * @notice Mock consumer for testing VRF functionality
 */
contract MockVRFConsumer is RannVRFConsumer {
    constructor(address vrfCoordinator) RannVRFConsumer(vrfCoordinator) {}

    function testGetInstantRandom() external view returns (uint256) {
        return _getInstantRandom();
    }

    function testGetBatchRandom(uint8 count) external view returns (uint256[] memory) {
        return _getBatchRandom(count);
    }

    function testGetRandomInRange(uint256 max) external view returns (uint256) {
        return _getRandomInRange(max);
    }

    function testGetRandomBetween(uint256 min, uint256 max) external view returns (uint256) {
        return _getRandomBetween(min, max);
    }

    function testGetRandomPercentage() external view returns (uint256) {
        return _getRandomPercentage();
    }

    function testGetRandomBool() external view returns (bool) {
        return _getRandomBool();
    }

    function testGetUniqueRandoms(uint8 count, uint256 max) external view returns (uint256[] memory) {
        return _getUniqueRandoms(count, max);
    }
}
