#!/bin/bash

echo "=========================================="
echo "🚀 Rann VRF Interactive Deployment"
echo "=========================================="
echo ""
echo "This will deploy RannVRFCoordinator to Base Sepolia testnet"
echo ""

# Prompt for private key
read -sp "Enter your private key (will be hidden): " PRIVATE_KEY
echo ""
echo ""

# Validate private key format
if [[ ! $PRIVATE_KEY =~ ^0x[0-9a-fA-F]{64}$ ]] && [[ ! $PRIVATE_KEY =~ ^[0-9a-fA-F]{64}$ ]]; then
    echo "⚠️  Invalid private key format"
    exit 1
fi

# Add 0x prefix if not present
if [[ ! $PRIVATE_KEY =~ ^0x ]]; then
    PRIVATE_KEY="0x$PRIVATE_KEY"
fi

export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"

echo "Deploying to Base Sepolia..."
echo "RPC: $BASE_SEPOLIA_RPC_URL"
echo ""

cd "/Users/apple/Desktop/Base Bataches"

forge script script/DeployVRFSimple.s.sol:DeployVRFSimple \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    -vvvv

echo ""
echo "=========================================="
echo "✅ Deployment Complete!"
echo "=========================================="
