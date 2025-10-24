# Rann VRF Quick Start Guide

## 🚀 5-Minute Integration

### Step 1: Deploy VRF (1 minute)

```bash
# Clone and setup
cd "Base Bataches"
forge install

# Deploy VRF Coordinator
forge script script/DeployRannVRF.s.sol:DeployVRFOnly \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --broadcast

# Save the deployed address
export VRF_COORDINATOR=0xYourDeployedAddress
```

### Step 2: Create Your Game Contract (2 minutes)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {RannVRFConsumer} from "./VRF/RannVRFConsumer.sol";

contract MyGame is RannVRFConsumer {
    constructor(address vrfCoordinator)
        RannVRFConsumer(vrfCoordinator)
    {}

    // Example 1: Dice roll (1-6)
    function rollDice() external view returns (uint256) {
        return _getRandomBetween(1, 6);
    }

    // Example 2: Coin flip
    function flipCoin() external view returns (bool) {
        return _getRandomBool();
    }

    // Example 3: Success check (percentage)
    function attemptAction(uint256 successRate) external view returns (bool) {
        uint256 roll = _getRandomPercentage(); // 0-9999
        return roll < successRate;
    }

    // Example 4: Draw 5 unique cards from 52
    function drawCards() external view returns (uint256[] memory) {
        return _getUniqueRandoms(5, 52);
    }

    // Example 5: Multiple actions in one transaction
    function playRound() external view returns (
        uint256 damage,
        bool criticalHit,
        uint256 loot
    ) {
        uint256[] memory randoms = _getBatchRandom(3);

        damage = (randoms[0] % 50) + 10;      // 10-59 damage
        criticalHit = (randoms[1] % 100) < 20; // 20% crit chance
        loot = randoms[2] % 1000;              // 0-999 gold
    }
}
```

### Step 3: Deploy & Test (2 minutes)

```bash
# Deploy your game
forge create src/MyGame.sol:MyGame \
    --constructor-args $VRF_COORDINATOR \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY

export MY_GAME=0xYourGameAddress

# Add your game as VRF consumer
cast send $VRF_COORDINATOR \
    "addConsumer(address)" $MY_GAME \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY

# Test it!
cast call $MY_GAME "rollDice()" --rpc-url $BASE_SEPOLIA_RPC_URL
# Returns: 4

cast call $MY_GAME "flipCoin()" --rpc-url $BASE_SEPOLIA_RPC_URL
# Returns: true
```

---

## 📚 Common Patterns

### Pattern 1: Battle System (like Kurukshetra)

```solidity
function executeBattle(uint256 attackerId, uint256 defenderId) external {
    // Get 2 random numbers in 1 call
    uint256[] memory randoms = _getBatchRandom(2);

    // Attacker's turn
    uint256 attackRoll = randoms[0] % 10000;
    if (attackRoll < attackSuccessRate) {
        dealDamage(defenderId, calculateDamage(attackerId));
    }

    // Defender's turn
    uint256 defendRoll = randoms[1] % 10000;
    if (defendRoll < defendSuccessRate) {
        dealDamage(attackerId, calculateDamage(defenderId));
    }
}
```

**Gas savings**: 1 VRF call instead of 2 (50% reduction)

### Pattern 2: Loot Box

```solidity
function openLootBox() external returns (uint256[] memory rewards) {
    // Get 3 rewards
    uint256[] memory randoms = _getBatchRandom(3);

    rewards = new uint256[](3);
    for (uint8 i = 0; i < 3; i++) {
        uint256 rarity = randoms[i] % 10000;

        if (rarity < 50) {
            rewards[i] = LEGENDARY; // 0.5%
        } else if (rarity < 500) {
            rewards[i] = EPIC;      // 4.5%
        } else if (rarity < 2000) {
            rewards[i] = RARE;      // 15%
        } else {
            rewards[i] = COMMON;    // 80%
        }
    }

    return rewards;
}
```

### Pattern 3: Tournament Matchmaking

```solidity
function createMatches(uint256 playerCount) external returns (uint256[][] memory) {
    require(playerCount % 2 == 0, "Need even number");

    // Shuffle all players
    uint256[] memory shuffled = _getUniqueRandoms(
        uint8(playerCount),
        playerCount
    );

    // Create pairs
    uint256[][] memory matches = new uint256[][](playerCount / 2);
    for (uint256 i = 0; i < playerCount; i += 2) {
        matches[i/2] = [shuffled[i], shuffled[i+1]];
    }

    return matches;
}
```

### Pattern 4: Training (like Gurukul)

```solidity
function selectQuestions(uint256 questionPoolSize) external view returns (uint256[] memory) {
    // Select 5 unique questions from pool
    return _getUniqueRandoms(5, questionPoolSize);

    // Old O(n²) method eliminated!
}
```

---

## 🎯 API Reference

### Basic Functions

```solidity
// Get single random number (0 to 2^256-1)
uint256 random = _getInstantRandom();

// Get multiple random numbers (gas efficient)
uint256[] memory randoms = _getBatchRandom(10);
```

### Range Functions

```solidity
// Random in range [0, max)
uint256 dice = _getRandomInRange(6); // 0-5

// Random between [min, max] inclusive
uint256 damage = _getRandomBetween(10, 50); // 10-50

// Random percentage (0-9999, basis points)
uint256 chance = _getRandomPercentage(); // 0-9999
```

### Special Functions

```solidity
// Random boolean (50/50)
bool coinFlip = _getRandomBool();

// N unique random numbers in range [0, max)
uint256[] memory unique = _getUniqueRandoms(5, 52); // 5 cards from 52
```

---

## ⚡ Performance Tips

### ✅ DO: Use Batch Operations

```solidity
// GOOD (1 VRF call, ~8,000 gas)
uint256[] memory randoms = _getBatchRandom(5);
uint256 a = randoms[0];
uint256 b = randoms[1];
uint256 c = randoms[2];
uint256 d = randoms[3];
uint256 e = randoms[4];
```

### ❌ DON'T: Multiple Single Calls

```solidity
// BAD (5 VRF calls, ~17,500 gas)
uint256 a = _getInstantRandom();
uint256 b = _getInstantRandom();
uint256 c = _getInstantRandom();
uint256 d = _getInstantRandom();
uint256 e = _getInstantRandom();
```

### ✅ DO: Use Helper Functions

```solidity
// GOOD (optimized)
uint256[] memory cards = _getUniqueRandoms(5, 52);
```

### ❌ DON'T: Implement Yourself

```solidity
// BAD (O(n²), multiple VRF calls)
uint256[] memory cards = new uint256[](5);
for (uint i = 0; i < 5; i++) {
    uint256 card = _getRandomInRange(52);
    // Check for duplicates...
}
```

---

## 🔒 Security Guidelines

### High Value Operations (>$1,000)

Use **request-fulfill pattern** for maximum security:

```solidity
uint256 public requestId;
bytes32 private constant SECRET = keccak256("my_secret");

function startHighValueOperation() external {
    requestId = _requestRandom(SECRET);
}

function completeHighValueOperation() external {
    require(_isRandomReady(requestId), "Not ready");
    uint256 random = _getFulfilledRandom(requestId);

    // Use random for high-value logic
    distributeRewards(random);
}
```

### Medium Value Operations ($10-$1,000)

Use **instant randomness** with additional checks:

```solidity
function mediumValueOperation() external {
    uint256 random = _getInstantRandom();

    // Add block delay to prevent same-block manipulation
    require(block.number > lastActionBlock[msg.sender] + 1, "Wait");

    // Use random
    grantReward(random);

    lastActionBlock[msg.sender] = block.number;
}
```

### Low Value Operations (<$10)

Use **instant randomness** freely:

```solidity
function lowValueOperation() external {
    uint256 random = _getInstantRandom();
    // No additional checks needed
    grantCosmetic(random);
}
```

---

## 🧪 Testing Your Integration

```solidity
// test/MyGame.t.sol
import {Test} from "forge-std/Test.sol";
import {MyGame} from "../src/MyGame.sol";
import {RannVRFCoordinator} from "../src/VRF/RannVRFCoordinator.sol";

contract MyGameTest is Test {
    MyGame game;
    RannVRFCoordinator vrf;

    function setUp() public {
        vrf = new RannVRFCoordinator();
        game = new MyGame(address(vrf));
        vrf.addConsumer(address(game));
    }

    function testDiceRoll() public {
        vm.roll(block.number + 1); // Advance block

        uint256 roll = game.rollDice();

        assertGe(roll, 1, "Dice should be >= 1");
        assertLe(roll, 6, "Dice should be <= 6");
    }

    function testCoinFlipDistribution() public {
        uint256 heads = 0;
        uint256 iterations = 100;

        for (uint i = 0; i < iterations; i++) {
            vm.roll(block.number + i + 1);

            if (game.flipCoin()) {
                heads++;
            }
        }

        // Should be roughly 50/50 (allow 30-70 range)
        assertGe(heads, 30, "Should have some heads");
        assertLe(heads, 70, "Should have some tails");
    }

    function testBatchOperations() public {
        vm.roll(block.number + 1);

        (uint256 damage, bool crit, uint256 loot) = game.playRound();

        assertGe(damage, 10, "Min damage");
        assertLe(damage, 59, "Max damage");
        assertLe(loot, 999, "Max loot");
    }
}
```

Run tests:
```bash
forge test --match-path test/MyGame.t.sol -vv
```

---

## 🐛 Troubleshooting

### Issue: "Unauthorized consumer"

**Solution**: Add your contract as consumer:
```bash
cast send $VRF_COORDINATOR \
    "addConsumer(address)" $YOUR_CONTRACT \
    --private-key $PRIVATE_KEY
```

### Issue: Returns 0 or same number

**Solution**: Advance block before calling:
```solidity
vm.roll(block.number + 1); // In tests

// In production, randomness is based on previous block
// so this shouldn't happen unless blockchain halted
```

### Issue: High gas costs

**Solution**: Use batch operations:
```solidity
// Instead of 5 calls:
uint256[] memory randoms = _getBatchRandom(5);
```

### Issue: Not truly random (tests)

**Solution**: This is expected in deterministic tests. For statistical tests:
```solidity
function testRandomDistribution() public {
    // Test over many iterations
    for (uint i = 0; i < 1000; i++) {
        vm.roll(block.number + i + 1); // Change entropy
        uint256 random = game.getRandom();
        // Collect statistics...
    }
}
```

---

## 📊 Gas Cost Reference

| Operation | Gas Cost | Equivalent To |
|-----------|----------|---------------|
| Single instant random | ~3,500 | 1 ERC20 transfer |
| Batch 5 randoms | ~8,000 | 2 ERC20 transfers |
| Batch 10 randoms | ~14,500 | 4 ERC20 transfers |
| Request randomness | ~25,000 | NFT mint |
| Fulfill randomness | ~100,000 | Complex swap |

**Comparison**:
- Chainlink VRF: 150,000 gas (43x more)
- Block.prevrandao: 200 gas (but insecure)
- Rann VRF: 3,500 gas ✅ Sweet spot

---

## 🎓 Next Steps

1. **Read full documentation**: [RANN_VRF_IMPLEMENTATION.md](./RANN_VRF_IMPLEMENTATION.md)

2. **Explore examples**:
   - [GurukulOptimized.sol](./src/Gurukul/GurukulOptimized.sol) - Training system
   - [KurukshetraOptimized.sol](./src/Kurukshetra/KurukshetraOptimized.sol) - Battle system

3. **Run tests**:
   ```bash
   forge test --match-path test/RannVRFTest.t.sol -vvv
   ```

4. **Deploy to production**:
   ```bash
   forge script script/DeployRannVRF.s.sol:DeployRannVRF \
       --rpc-url $BASE_MAINNET_RPC_URL \
       --broadcast \
       --verify
   ```

---

## 💡 Pro Tips

1. **Always use batch operations** when you need multiple randoms
2. **Use helper functions** instead of implementing yourself
3. **Test randomness distribution** over many iterations
4. **Add block delays** for medium-value operations
5. **Use request-fulfill** for high-value operations
6. **Monitor gas costs** with `forge test --gas-report`
7. **Implement fallbacks** for better UX
8. **Document your random usage** for auditors

---

## 🤝 Need Help?

- **Documentation**: [Full guide](./RANN_VRF_IMPLEMENTATION.md)
- **Examples**: Check [src/](./src/) folder
- **Tests**: Check [test/](./test/) folder
- **Issues**: Open a GitHub issue

Happy building! 🚀
