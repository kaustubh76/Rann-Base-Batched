# Deploy Base Bataches to Vercel

This guide will help you deploy the Base Bataches project to Vercel.

## Prerequisites

- GitHub account
- Vercel account (sign up at [vercel.com](https://vercel.com))
- This repository pushed to GitHub

## Step 1: Push to GitHub

Make sure your code is pushed to a GitHub repository:

```bash
git add .
git commit -m "Prepare for Vercel deployment"
git push origin main
```

## Step 2: Import Project to Vercel

1. Go to [vercel.com](https://vercel.com) and sign in
2. Click **"Add New..."** → **"Project"**
3. Import your GitHub repository
4. Vercel will auto-detect Next.js

## Step 3: Configure Project Settings

### Root Directory
- **Set Root Directory to:** `frontend`
- This is IMPORTANT because your Next.js app is in the `frontend` folder

### Build Settings
Vercel should auto-detect these, but verify:
- **Framework Preset:** Next.js
- **Build Command:** `npm run build`
- **Output Directory:** `.next`
- **Install Command:** `npm install`

## Step 4: Set Environment Variables

In Vercel project settings, add these environment variables:

### Required Variables

```bash
# WalletConnect
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=c18217d2c313c54c0fc5149a23f3faf0

# NEAR AI Configuration
NEAR_AGENT_PRIVATE_KEY=ed25519:4cQdCB1vydmo1kZ4utxMeQKziEa1DHX3Gr7guGuBztkRtpdUQbubaob4eB6XV464WBrtyUDQXXEtJkpEyji9Jpz1
NEAR_AGENT_ACCOUNT_ID=samkitsoni.near

# Game Master
NEXT_PUBLIC_GAME_MASTER_PRIVATE_KEY=0x860c4d18569ec3e4a799bf65d6fbb0cf8f272eabcc3264966f60dad165681f4f

# Pinata/IPFS
PINATA_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJiYmM1NjEyYi0zOWZjLTQxZGYtYTk3Yi00OWI2ZTVlNDdmZTgiLCJlbWFpbCI6ImFnYXJ3YWwueXVnMTk3NkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGluX3BvbGljeSI6eyJyZWdpb25zIjpbeyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJGUkExIn0seyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJOWUMxIn1dLCJ2ZXJzaW9uIjoxfSwibWZhX2VuYWJsZWQiOmZhbHNlLCJzdGF0dXMiOiJBQ1RJVkUifSwiYXV0aGVudGljYXRpb25UeXBlIjoic2NvcGVkS2V5Iiwic2NvcGVkS2V5S2V5IjoiNDEyNzkxNWY5M2U1MjZiNTRkZDYiLCJzY29wZWRLZXlTZWNyZXQiOiIzNjIxZjk0MDQ5YTM4NTI5NjRhMDI1MmVkYzU2ZjQ2MmM5YjM4ZDFmODhmY2M5ZGQ4NmI3YWRhYmI0ZGNjNmI2IiwiZXhwIjoxNzgyNDIwNzE1fQ.iKDq-JcSesbHsacKgtmmEHRjF4-11Esh68MT3HvJyMA
NEXT_PUBLIC_GATEWAY_URL=https://fuchsia-cheap-bat-157.mypinata.cloud/ipfs/

# NEAR AI Auth
NEXT_PUBLIC_AUTH_KEY={"message":"Login to NEAR AI","nonce":"1750857441779","recipient":"ai.near","callback_url":"http://localhost:3000/","signature":"i7Ah1PI+C5btN+KQUE13VHUENU/sHwzu0H6NE1+FO0gzfT0dqGq13nEdzQvhKNPF2vDS7uo6Ii7C+Q6SLkMVCQ==","account_id":"samkitsoni.near","public_key":"ed25519:DF2u3QrdU6NbbudHjdrrWHsNNkurfRFUXmDnTDUkfKDF"}

# Base Sepolia RPC
NEXT_PUBLIC_BASE_SEPOLIA_RPC=https://sepolia.base.org
```

### How to Add Environment Variables in Vercel:

1. Go to your project in Vercel
2. Click **"Settings"** → **"Environment Variables"**
3. Add each variable one by one:
   - Name: `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID`
   - Value: `c18217d2c313c54c0fc5149a23f3faf0`
   - Environment: Select **Production**, **Preview**, and **Development**
4. Click **"Save"**
5. Repeat for all variables above

## Step 5: Deploy

1. Click **"Deploy"**
2. Vercel will build and deploy your app
3. Wait for the build to complete (usually 2-3 minutes)

## Step 6: Update Callback URLs

After deployment, you'll need to update callback URLs:

1. Note your Vercel URL (e.g., `https://your-app.vercel.app`)
2. Update `NEXT_PUBLIC_AUTH_KEY` to use your production URL instead of `localhost:3000`
3. Redeploy if necessary

## Troubleshooting

### Build Fails with "indexedDB is not defined"
This is expected and won't prevent deployment. The error occurs during SSR but doesn't affect the production app.

### Environment Variables Not Working
- Make sure you clicked "Save" for each variable
- Ensure you selected all environments (Production, Preview, Development)
- Try redeploying after adding variables

### 404 on Routes
- Verify Root Directory is set to `frontend`
- Check that vercel.json is present in the frontend folder

### API Routes Not Working
Make sure your API routes are in `frontend/src/app/api/` directory.

## Post-Deployment

After successful deployment:

1. **Test the site:** Visit your Vercel URL
2. **Connect wallet:** Test WalletConnect functionality
3. **Test IPFS uploads:** Try minting a Yodha
4. **Check API routes:** Verify all API endpoints work

## Automatic Deployments

Once set up, Vercel will automatically deploy:
- **Production:** Every push to `main` branch
- **Preview:** Every push to other branches and PRs

## Need Help?

- [Vercel Documentation](https://vercel.com/docs)
- [Next.js on Vercel](https://vercel.com/docs/frameworks/nextjs)
- Check the build logs in Vercel dashboard for specific errors

## Your Deployed Contracts (Already on Base Sepolia)

These are already configured in your code:
- **RannToken:** `0xdff6c8409fae4253e207df8d2d0de0eaf79674e5`
- **YodhaNFT:** `0xccce492f07c866b4f8b0fba1e0a5f102c8a92a68`
- **Bazaar:** `0xaaf1e4610707bd9b0e70aac7dfcbe183b771df61`
- **Gurukul:** `0x84270ed3b1e47adaf7e03514fbd6e30e107a46c5`
- **KurukshetraFactory:** `0x3ca84d579d5c9e1b0561becb5c7fbaa5209636e8`

No smart contract deployment needed - just deploy the frontend!
