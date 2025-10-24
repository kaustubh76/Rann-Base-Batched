# Deployment Guide - Base Sepolia

## Overview

Rann is deployed on Base Sepolia testnet with all smart contracts verified and functional.

## Deployed Contracts

### Base Sepolia (Chain ID: 84532)

| Contract | Address | Verified |
|----------|---------|----------|
| **RannToken** | `0xdff6c8409fae4253e207df8d2d0de0eaf79674e5` | ✅ [View](https://sepolia.basescan.org/address/0xdff6c8409fae4253e207df8d2d0de0eaf79674e5) |
| **YodhaNFT** | `0xccce492f07c866b4f8b0fba1e0a5f102c8a92a68` | ✅ [View](https://sepolia.basescan.org/address/0xccce492f07c866b4f8b0fba1e0a5f102c8a92a68) |
| **KurukshetraFactory** | `0x3ca84d579d5c9e1b0561becb5c7fbaa5209636e8` | ✅ [View](https://sepolia.basescan.org/address/0x3ca84d579d5c9e1b0561becb5c7fbaa5209636e8) |
| **Bazaar** | `0xaaf1e4610707bd9b0e70aac7dfcbe183b771df61` | ✅ [View](https://sepolia.basescan.org/address/0xaaf1e4610707bd9b0e70aac7dfcbe183b771df61) |
| **Gurukul** | `0x84270ed3b1e47adaf7e03514fbd6e30e107a46c5` | ✅ [View](https://sepolia.basescan.org/address/0x84270ed3b1e47adaf7e03514fbd6e30e107a46c5) |

## Network Configuration

### Base Sepolia Details
- **Network Name**: Base Sepolia
- **Chain ID**: 84532
- **RPC URL**: https://sepolia.base.org
- **Currency Symbol**: ETH
- **Block Explorer**: https://sepolia.basescan.org

### Faucets
- **Base Sepolia ETH**: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
- **Alternative**: https://faucet.quicknode.com/base/sepolia

## Contract Interactions

### Minting RANN Tokens
```bash
# Mint 1 RANN token (1:1 with ETH)
cast send 0xdff6c8409fae4253e207df8d2d0de0eaf79674e5 \
  "mint(uint256)" \
  1000000000000000000 \
  --value 1000000000000000000 \
  --rpc-url https://sepolia.base.org \
  --private-key $PRIVATE_KEY
```

### Checking RANN Balance
```bash
cast call 0xdff6c8409fae4253e207df8d2d0de0eaf79674e5 \
  "balanceOf(address)" \
  $YOUR_ADDRESS \
  --rpc-url https://sepolia.base.org
```

### Minting NFT
Use the frontend at https://rann-blue.vercel.app/chaavani

## Frontend Configuration

Update `frontend/.env.local` with:
```bash
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id
NEAR_AGENT_PRIVATE_KEY=your_near_key
NEAR_AGENT_ACCOUNT_ID=your_near_account
NEXT_PUBLIC_GAME_MASTER_PRIVATE_KEY=your_game_master_key
PINATA_JWT=your_pinata_jwt
NEXT_PUBLIC_GATEWAY_URL=https://gateway.pinata.cloud/ipfs/
NEXT_PUBLIC_AUTH_KEY=your_auth_key
```

See `frontend/.env.local.example` for full configuration.

## Testing

### Running Tests
```bash
forge test
```

### Deploying to Base Sepolia
```bash
# Set environment variables
export PRIVATE_KEY="your_private_key"
export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"
export BASESCAN_API_KEY="your_basescan_api_key"

# Deploy contracts
forge script script/DeployRann.s.sol:DeployRann \
  --rpc-url $BASE_SEPOLIA_RPC_URL \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY \
  -vvvv
```

## Gas Costs (Base Sepolia)

| Operation | Estimated Gas | Cost (Gwei) |
|-----------|---------------|-------------|
| Mint RANN Token | ~50,000 | ~0.00005 ETH |
| Mint Yodha NFT | ~200,000 | ~0.0002 ETH |
| Initialize Battle | ~150,000 | ~0.00015 ETH |
| Place Bet | ~80,000 | ~0.00008 ETH |
| Execute Battle Round | ~250,000 | ~0.00025 ETH |
| Train in Gurukul | ~120,000 | ~0.00012 ETH |

*Costs based on 1 gwei gas price*

## Troubleshooting

### Transaction Fails
- Ensure sufficient Base Sepolia ETH balance
- Check gas limit and gas price
- Verify network connection

### Frontend Won't Connect
- Ensure MetaMask is on Base Sepolia (Chain ID: 84532)
- Check that contract addresses in `constants.ts` match deployed addresses
- Clear browser cache and reconnect wallet

### NFT Minting Issues
- Verify NEAR AI agents are responding
- Check IPFS upload succeeded
- Ensure RANN token approval for NFT contract

## Support

For issues or questions:
- GitHub Issues: [Create Issue](https://github.com/samkitsoni/rann-game-platform/issues)
- Documentation: See [README.md](README.md)
- Hackathon Submission: See [HACKATHON_SUBMISSION.md](HACKATHON_SUBMISSION.md)
