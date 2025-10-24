#!/bin/bash

# Deployment Script for Rann VRF
# Usage: ./deploy.sh

echo "=========================================="
echo "Rann VRF Deployment Script"
echo "=========================================="
echo ""

# Check if private key is set
if [ -z "$PRIVATE_KEY" ]; then
    echo "⚠️  PRIVATE_KEY not set!"
    echo ""
    echo "Please set your private key:"
    echo "export PRIVATE_KEY=\"your_private_key_here\""
    echo ""
    exit 1
fi

# Set RPC URL
export BASE_SEPOLIA_RPC_URL="https://sepolia.base.org"

# Optional: Set API key for verification
if [ -z "$BASESCAN_API_KEY" ]; then
    echo "ℹ️  BASESCAN_API_KEY not set (contract won't be auto-verified)"
    echo "You can verify manually later"
    echo ""
    VERIFY_FLAG=""
else
    VERIFY_FLAG="--verify --etherscan-api-key $BASESCAN_API_KEY"
fi

echo "Deploying to Base Sepolia..."
echo "RPC: $BASE_SEPOLIA_RPC_URL"
echo ""

# Deploy
cd "/Users/apple/Desktop/Base Bataches"

forge script script/DeployVRFSimple.s.sol:DeployVRFSimple \
    --rpc-url $BASE_SEPOLIA_RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    $VERIFY_FLAG \
    -vvvv

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Check the output above for your deployed contract address"
echo "Save it with: export VRF_COORDINATOR=\"0xYourAddress\""
