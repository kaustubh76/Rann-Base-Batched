# Base Sepolia Deployment Guide

## Overview
This document provides comprehensive instructions for deploying the Rann AI-Powered Web3 Battle Arena to Base Sepolia testnet.

## Changes Made for Base Sepolia Migration

### 1. Smart Contract Configuration
- ✅ Updated `script/HelperConfig.s.sol` to support Base Sepolia (Chain ID: 84532)
- ✅ Added Base Mainnet configuration (Chain ID: 8453)
- ✅ Kept Flow VRF implementation intact (will be updated separately)

### 2. Frontend Configuration
- ✅ Updated `frontend/src/rainbowKitConfig.tsx` to use Base Sepolia and Base Mainnet
- ✅ Updated `frontend/src/constants.ts` with Base Sepolia chain ID (84532)
- ✅ Added placeholder contract addresses for Base Sepolia deployment

### 3. Dependencies
- ✅ Initialized git repository
- ✅ Installed Foundry dependencies (forge-std, openzeppelin-contracts)

## Prerequisites

### Required Tools
1. **Foundry** - Smart contract development framework
   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Node.js & npm** - Version 18.0.0 or higher
   ```bash
   node --version  # Should be >= 18.0.0
   npm --version   # Should be >= 8.0.0
   ```

3. **Private Key** - For contract deployment
   - Create a new wallet for deployment
   - Fund it with Base Sepolia ETH from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)

## Deployment Steps

### Step 1: Environment Setup

Create a `.env` file in the project root:

```bash
# Deployment
PRIVATE_KEY=your_deployer_private_key_here
BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
BASESCAN_API_KEY=your_basescan_api_key_here

# Game Configuration
GAME_MASTER_PUBLIC_KEY=0x5c6E63E3681D4EB7dEeaA0B4e6C552C636d28263
DAO_ADDRESS=0x456  # Update with actual DAO address

# Frontend Environment (.env.local in frontend/)
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_wallet_connect_project_id
NEAR_AGENT_PRIVATE_KEY=your_near_private_key
NEAR_AGENT_ACCOUNT_ID=your_near_account_id
NEXT_PUBLIC_GAME_MASTER_PRIVATE_KEY=your_game_master_private_key
PINATA_JWT=your_pinata_jwt_token
NEXT_PUBLIC_GATEWAY_URL=https://gateway.pinata.cloud/ipfs/
NEXT_PUBLIC_AUTH_KEY=your_auth_key
```

### Step 2: Compile Smart Contracts

```bash
forge build
```

Expected output:
```
Compiling 61 files with Solc 0.8.29
Solc 0.8.29 finished in X.XXs
Compiler run successful!
```

### Step 3: Deploy Contracts to Base Sepolia

```bash
# Load environment variables
source .env

# Deploy contracts
forge script script/DeployRann.s.sol:DeployRann \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY \
    -vvvv
```

### Step 4: Record Deployed Contract Addresses

After deployment, you'll see output like:
```
== Logs ==
  RannToken deployed at: 0x...
  YodhaNFT deployed at: 0x...
  Gurukul deployed at: 0x...
  Bazaar deployed at: 0x...
  KurukshetraFactory deployed at: 0x...
```

**Save these addresses!** You'll need them for the next step.

### Step 5: Update Frontend Configuration

Update `frontend/src/constants.ts` with the deployed contract addresses:

```typescript
export const chainsToTSender: ContractsConfig = {
    // Base Sepolia (Primary deployment)
    84532: {
        rannToken: "0xYOUR_RANN_TOKEN_ADDRESS",
        yodhaNFT: "0xYOUR_YODHA_NFT_ADDRESS",
        Bazaar: "0xYOUR_BAZAAR_ADDRESS",
        Gurukul: "0xYOUR_GURUKUL_ADDRESS",
        KurukshetraFactory: "0xYOUR_KURUKSHETRA_FACTORY_ADDRESS"
    }
}
```

### Step 6: Create Initial Arenas

After deployment, create the 4 initial battle arenas:

```bash
# Create Bronze Arena
cast send $KURUKSHETRA_FACTORY_ADDRESS \
    "makeNewArena(uint256,uint256,uint256,uint8)" \
    50000000000000 \     # costToInfluence (0.00005 ETH)
    100000000000000 \    # costToDefluence (0.0001 ETH)
    1000000000000000 \   # betAmount (0.001 ETH)
    1 \                  # BRONZE ranking
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY

# Repeat for SILVER (2), GOLD (3), and PLATINUM (4) arenas
```

### Step 7: Frontend Deployment

```bash
cd frontend

# Install dependencies
npm install

# Build for production
npm run build

# Deploy to Vercel (recommended)
# 1. Install Vercel CLI: npm i -g vercel
# 2. Run: vercel --prod

# Or deploy to your preferred hosting platform
```

### Step 8: Configure Frontend Environment Variables

In your hosting platform (Vercel/Netlify/etc.), set these environment variables:

```
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id
NEAR_AGENT_PRIVATE_KEY=your_near_private_key
NEAR_AGENT_ACCOUNT_ID=your_near_account_id
NEXT_PUBLIC_GAME_MASTER_PRIVATE_KEY=your_game_master_private_key
PINATA_JWT=your_pinata_jwt_token
NEXT_PUBLIC_GATEWAY_URL=https://gateway.pinata.cloud/ipfs/
NEXT_PUBLIC_AUTH_KEY=your_auth_key
```

## Base Sepolia Network Details

| Parameter | Value |
|-----------|-------|
| **Network Name** | Base Sepolia |
| **Chain ID** | 84532 |
| **RPC URL** | https://sepolia.base.org |
| **Currency Symbol** | ETH |
| **Block Explorer** | https://sepolia.basescan.org |

## Faucets for Testing

- **Base Sepolia ETH**: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
- **Alternative Faucet**: https://faucet.quicknode.com/base/sepolia

## Contract Verification

Contracts should auto-verify during deployment. If verification fails:

```bash
forge verify-contract \
    --chain-id 84532 \
    --num-of-optimizations 200 \
    --watch \
    --constructor-args $(cast abi-encode "constructor(address,address)" "$DAO_ADDRESS" "$GAME_MASTER_PUBLIC_KEY") \
    --etherscan-api-key $BASESCAN_API_KEY \
    --compiler-version v0.8.24+commit.e11b9ed9 \
    $CONTRACT_ADDRESS \
    src/Chaavani/YodhaNFT.sol:YodhaNFT
```

## Testing the Deployment

### 1. Test Token Minting
```bash
# Mint RANN tokens (1:1 with ETH)
cast send $RANN_TOKEN_ADDRESS \
    "mint(uint256)" \
    1000000000000000000 \  # 1 RANN
    --value 1000000000000000000 \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY
```

### 2. Test NFT Minting
Use the frontend at your deployed URL:
1. Connect MetaMask to Base Sepolia
2. Navigate to Chaavani page
3. Upload an image
4. Mint your first Yodha NFT

### 3. Test Battle Arena
1. Get your NFT ranked (accumulate winnings)
2. Initialize a battle
3. Place bets during the 70-second betting period
4. Watch autonomous AI battle execution

## Troubleshooting

### Issue: "Insufficient funds for gas"
**Solution**: Ensure your deployer wallet has enough Base Sepolia ETH

### Issue: "Contract verification failed"
**Solution**: Manually verify using the forge verify-contract command above

### Issue: "Transaction reverted"
**Solution**: Check that:
- All constructor parameters are correct
- VRF address (cadenceArch) is properly set
- Game Master public key matches your backend

### Issue: "Frontend not connecting to contracts"
**Solution**:
- Verify chain ID is 84532 in constants.ts
- Check that contract addresses are correctly updated
- Ensure MetaMask is connected to Base Sepolia

## Post-Deployment Checklist

- [ ] All 5 contracts deployed successfully
- [ ] Contracts verified on BaseScan
- [ ] Frontend updated with new contract addresses
- [ ] All 4 arenas created (Bronze, Silver, Gold, Platinum)
- [ ] Test RANN token minting works
- [ ] Test NFT minting with NEAR AI integration
- [ ] Test battle initialization and execution
- [ ] Frontend deployed and accessible
- [ ] Documentation updated with new addresses

## Important Notes

### VRF Implementation
The current VRF implementation uses Flow's Cadence Arch. For Base Sepolia, you have two options:

1. **Keep Flow VRF (Temporary)**: Set `cadenceArch` to a placeholder address for now
2. **Integrate Chainlink VRF** (Recommended for production):
   - Follow Chainlink VRF V2.5 documentation
   - Update Kurukshetra.sol and Gurukul.sol
   - Deploy VRF Coordinator subscription

### NEAR AI Integration
- NEAR AI agents remain unchanged
- Backend must sign all AI-generated data with ECDSA
- Public key must match the one set during deployment

### Security Considerations
- Change all default addresses before mainnet deployment
- Use hardware wallet for DAO operations
- Implement multi-sig for critical functions
- Audit all contracts before production use

## Support & Resources

- **Base Documentation**: https://docs.base.org
- **Foundry Book**: https://book.getfoundry.sh
- **NEAR AI**: https://app.near.ai
- **Project Repository**: https://github.com/samkitsoni/rann-game-platform

## Next Steps

After successful deployment:
1. Update README.md with new Base Sepolia addresses
2. Test all game mechanics thoroughly
3. Gather community feedback
4. Plan mainnet deployment strategy
5. Consider implementing Chainlink VRF for production

---

**Deployment Date**: Update after deployment
**Deployed By**: Your Team Name
**Network**: Base Sepolia Testnet
**Status**: Ready for Hackathon Submission
