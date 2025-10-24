# Rann VRF Deployment Guide

## Prerequisites

1. **Foundry installed**
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Private key with funds on Base Sepolia**
   - Get testnet ETH from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
   - Or bridge from Sepolia ETH

3. **BaseScan API key** (for verification)
   - Get from [BaseScan](https://basescan.org/apis)

## Quick Deployment (Base Sepolia)

### Step 1: Set Environment Variables

```bash
# Export your private key (DO NOT commit this!)
export PRIVATE_KEY="your_private_key_here"

# Base Sepolia RPC URL (public endpoint)
export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"

# BaseScan API key for contract verification
export BASESCAN_API_KEY="your_basescan_api_key"
```

### Step 2: Deploy VRF Coordinator

```bash
cd "/Users/apple/Desktop/Base Bataches"

# Deploy RannVRFCoordinator
forge script script/DeployVRFSimple.s.sol:DeployVRFSimple \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY \
    -vvvv
```

**Expected Output:**
```
========================================
Deploying RannVRFCoordinator
========================================
Chain ID: 84532
Deployer: 0xYourAddress

========================================
Deployment Complete!
========================================
RannVRFCoordinator: 0xDeployedAddress
Owner: 0xYourAddress

Next Steps:
1. Add consumers: coordinator.addConsumer(address)
2. Add fulfillers: coordinator.addFulfiller(address)
3. Test randomness generation
========================================
```

### Step 3: Save Deployed Address

```bash
# Save the deployed VRF Coordinator address
export VRF_COORDINATOR="0xYourDeployedAddress"
```

### Step 4: Configure Access Control

```bash
# Add a fulfiller (can be your address initially)
cast send $VRF_COORDINATOR \
    "addFulfiller(address)" $YOUR_FULFILLER_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY

# Add a consumer contract
cast send $VRF_COORDINATOR \
    "addConsumer(address)" $YOUR_CONSUMER_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

### Step 5: Test VRF Randomness

```bash
# Test if fulfiller is authorized
cast call $VRF_COORDINATOR \
    "isFulfiller(address)" $YOUR_FULFILLER_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC_URL

# Test if consumer is authorized
cast call $VRF_COORDINATOR \
    "isConsumer(address)" $YOUR_CONSUMER_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC_URL
```

## Deploying GurukulOptimized

### Prerequisites
- RannVRFCoordinator already deployed
- YodhaNFT contract deployed
- DAO address configured
- NEAR AI public key available

### Deployment Command

```bash
# Update these with your actual addresses
export VRF_COORDINATOR="0xYourVRFAddress"
export DAO_ADDRESS="0xYourDAOAddress"
export YODHA_NFT="0xYourYodhaNFTAddress"
export NEAR_AI_PUBLIC_KEY="0xYourNearAIKey"

# Deploy GurukulOptimized
forge create src/Gurukul/GurukulOptimized.sol:GurukulOptimized \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --constructor-args \
        $VRF_COORDINATOR \
        $DAO_ADDRESS \
        $YODHA_NFT \
        10 \
        "[4,4,4,4,4,4,4,4,4,4]" \
        "QmXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX" \
        $NEAR_AI_PUBLIC_KEY \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY

# Authorize Gurukul as VRF consumer
cast send $VRF_COORDINATOR \
    "addConsumer(address)" $GURUKUL_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

## Deploying KurukshetraOptimized

### Prerequisites
- RannVRFCoordinator already deployed
- RannToken contract deployed
- YodhaNFT contract deployed
- KurukshetraFactory deployed
- NEAR AI public key available

### Deployment Command

```bash
# Update these with your actual addresses
export VRF_COORDINATOR="0xYourVRFAddress"
export RANN_TOKEN="0xYourRannTokenAddress"
export YODHA_NFT="0xYourYodhaNFTAddress"
export NEAR_AI_PUBLIC_KEY="0xYourNearAIKey"
export KURUKSHETRA_FACTORY="0xYourFactoryAddress"

# Deploy KurukshetraOptimized
forge create src/Kurukshetra/KurukshetraOptimized.sol:KurukshetraOptimized \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --constructor-args \
        $VRF_COORDINATOR \
        $RANN_TOKEN \
        $YODHA_NFT \
        $NEAR_AI_PUBLIC_KEY \
        1 \
        "100000000000000000000" \
        "10000000000000000000" \
        "50000000000000000000" \
        $KURUKSHETRA_FACTORY \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY

# Authorize Kurukshetra as VRF consumer
cast send $VRF_COORDINATOR \
    "addConsumer(address)" $KURUKSHETRA_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

## Verification Only (If deployment succeeded but verification failed)

```bash
# Verify RannVRFCoordinator
forge verify-contract \
    --chain-id 84532 \
    --num-of-optimizations 200 \
    --watch \
    --etherscan-api-key $BASESCAN_API_KEY \
    $VRF_COORDINATOR \
    src/VRF/RannVRFCoordinator.sol:RannVRFCoordinator
```

## Testing Deployed Contracts

### Test VRF Instant Randomness

Create a test consumer contract or use cast:

```solidity
// TestConsumer.sol
contract TestConsumer is RannVRFConsumer {
    constructor(address vrfCoordinator) RannVRFConsumer(vrfCoordinator) {}

    function testRandom() external view returns (uint256) {
        return _getInstantRandom();
    }
}
```

Deploy and test:

```bash
forge create TestConsumer \
    --constructor-args $VRF_COORDINATOR \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY

# Add as consumer
cast send $VRF_COORDINATOR \
    "addConsumer(address)" $TEST_CONSUMER \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY

# Test randomness
cast call $TEST_CONSUMER "testRandom()" \
    --rpc-url $BASE_SEPOLIA_RPC_URL
```

## Common Issues

### Issue 1: "Insufficient funds"
**Solution**: Get more testnet ETH from the Base Sepolia faucet

### Issue 2: "Nonce too low"
**Solution**: Wait a few blocks and retry, or manually set nonce:
```bash
--nonce $(cast nonce $YOUR_ADDRESS --rpc-url $BASE_SEPOLIA_RPC_URL)
```

### Issue 3: "Contract verification failed"
**Solution**: Retry verification separately:
```bash
forge verify-contract --chain-id 84532 $CONTRACT_ADDRESS $CONTRACT_PATH
```

### Issue 4: "Unauthorized consumer"
**Solution**: Make sure to call `addConsumer()` after deployment:
```bash
cast send $VRF_COORDINATOR "addConsumer(address)" $CONSUMER_ADDRESS
```

## Network Information

### Base Sepolia Testnet

| Parameter | Value |
|-----------|-------|
| Chain ID | 84532 |
| RPC URL | https://sepolia.base.org |
| Explorer | https://sepolia.basescan.org |
| Faucet | https://www.coinbase.com/faucets/base-ethereum-goerli-faucet |

### Base Mainnet

| Parameter | Value |
|-----------|-------|
| Chain ID | 8453 |
| RPC URL | https://mainnet.base.org |
| Explorer | https://basescan.org |

## Gas Estimates

| Contract | Deployment Gas | USD Cost (at 1 gwei, $3000 ETH) |
|----------|---------------|----------------------------------|
| RannVRFCoordinator | ~2,000,000 | ~$6 |
| GurukulOptimized | ~3,500,000 | ~$10.50 |
| KurukshetraOptimized | ~4,500,000 | ~$13.50 |
| **Total** | **~10,000,000** | **~$30** |

**Note**: Base Sepolia is free (testnet), mainnet costs vary with gas prices

## Post-Deployment Checklist

- [ ] VRF Coordinator deployed and verified
- [ ] Owner address confirmed
- [ ] Fulfillers added
- [ ] Consumers authorized
- [ ] Test randomness generation working
- [ ] Gurukul deployed (if needed)
- [ ] Gurukul authorized as consumer
- [ ] Kurukshetra deployed (if needed)
- [ ] Kurukshetra authorized as consumer
- [ ] Frontend updated with new addresses
- [ ] Documentation updated
- [ ] Security review completed

## Mainnet Deployment

⚠️ **WARNING**: Mainnet deployment requires careful consideration:

1. **Security audit** of all contracts
2. **Test extensively** on testnet first
3. **Use hardware wallet** or multi-sig for deployment
4. **Double-check all addresses** before deployment
5. **Start with small amounts** for testing
6. **Monitor** for unusual activity
7. **Have emergency pause** mechanism ready

### Mainnet Deployment Command

```bash
# Use mainnet RPC
export BASE_MAINNET_RPC_URL="https://mainnet.base.org"

# Deploy (ONLY after thorough testing!)
forge script script/DeployVRFSimple.s.sol:DeployVRFSimple \
    --rpc-url $BASE_MAINNET_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY \
    -vvvv
```

## Support

- Documentation: [RANN_VRF_IMPLEMENTATION.md](./RANN_VRF_IMPLEMENTATION.md)
- Quick Start: [VRF_QUICK_START.md](./VRF_QUICK_START.md)
- Issues: Open a GitHub issue
