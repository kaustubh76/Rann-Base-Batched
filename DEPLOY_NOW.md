# 🚀 Deploy to Vercel NOW - Quick Guide

Your project is **100% ready** for Vercel deployment!

## ✅ What's Been Done

- ✅ Build tested successfully - no errors
- ✅ TypeScript errors fixed
- ✅ Vercel configuration files created
- ✅ Environment variables documented
- ✅ All contracts deployed on Base Sepolia

## 🎯 3-Step Deployment

### Step 1: Push to GitHub (if not already done)

```bash
git add .
git commit -m "Ready for Vercel deployment"
git push origin main
```

### Step 2: Deploy on Vercel

1. Go to [vercel.com/new](https://vercel.com/new)
2. **Import your GitHub repository**
3. **IMPORTANT:** Set **Root Directory** to `frontend`
4. Click **Deploy**

### Step 3: Add Environment Variables

After deployment, go to **Settings** → **Environment Variables** and add:

```env
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=c18217d2c313c54c0fc5149a23f3faf0
NEAR_AGENT_PRIVATE_KEY=ed25519:4cQdCB1vydmo1kZ4utxMeQKziEa1DHX3Gr7guGuBztkRtpdUQbubaob4eB6XV464WBrtyUDQXXEtJkpEyji9Jpz1
NEAR_AGENT_ACCOUNT_ID=samkitsoni.near
NEXT_PUBLIC_GAME_MASTER_PRIVATE_KEY=0x860c4d18569ec3e4a799bf65d6fbb0cf8f272eabcc3264966f60dad165681f4f
PINATA_JWT=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySW5mb3JtYXRpb24iOnsiaWQiOiJiYmM1NjEyYi0zOWZjLTQxZGYtYTk3Yi00OWI2ZTVlNDdmZTgiLCJlbWFpbCI6ImFnYXJ3YWwueXVnMTk3NkBnbWFpbC5jb20iLCJlbWFpbF92ZXJpZmllZCI6dHJ1ZSwicGluX3BvbGljeSI6eyJyZWdpb25zIjpbeyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJGUkExIn0seyJkZXNpcmVkUmVwbGljYXRpb25Db3VudCI6MSwiaWQiOiJOWUMxIn1dLCJ2ZXJzaW9uIjoxfSwibWZhX2VuYWJsZWQiOmZhbHNlLCJzdGF0dXMiOiJBQ1RJVkUifSwiYXV0aGVudGljYXRpb25UeXBlIjoic2NvcGVkS2V5Iiwic2NvcGVkS2V5S2V5IjoiNDEyNzkxNWY5M2U1MjZiNTRkZDYiLCJzY29wZWRLZXlTZWNyZXQiOiIzNjIxZjk0MDQ5YTM4NTI5NjRhMDI1MmVkYzU2ZjQ2MmM5YjM4ZDFmODhmY2M5ZGQ4NmI3YWRhYmI0ZGNjNmI2IiwiZXhwIjoxNzgyNDIwNzE1fQ.iKDq-JcSesbHsacKgtmmEHRjF4-11Esh68MT3HvJyMA
NEXT_PUBLIC_GATEWAY_URL=https://fuchsia-cheap-bat-157.mypinata.cloud/ipfs/
NEXT_PUBLIC_AUTH_KEY={"message":"Login to NEAR AI","nonce":"1750857441779","recipient":"ai.near","callback_url":"http://localhost:3000/","signature":"i7Ah1PI+C5btN+KQUE13VHUENU/sHwzu0H6NE1+FO0gzfT0dqGq13nEdzQvhKNPF2vDS7uo6Ii7C+Q6SLkMVCQ==","account_id":"samkitsoni.near","public_key":"ed25519:DF2u3QrdU6NbbudHjdrrWHsNNkurfRFUXmDnTDUkfKDF"}
NEXT_PUBLIC_BASE_SEPOLIA_RPC=https://sepolia.base.org
```

**Important:** Select **Production**, **Preview**, and **Development** for each variable.

Then **Redeploy** your project.

## 🎮 Your Deployed Contracts

Already live on Base Sepolia:

- **RannToken:** `0xdff6c8409fae4253e207df8d2d0de0eaf79674e5`
- **YodhaNFT:** `0xccce492f07c866b4f8b0fba1e0a5f102c8a92a68`
- **Bazaar:** `0xaaf1e4610707bd9b0e70aac7dfcbe183b771df61`
- **Gurukul:** `0x84270ed3b1e47adaf7e03514fbd6e30e107a46c5`
- **KurukshetraFactory:** `0x3ca84d579d5c9e1b0561becb5c7fbaa5209636e8`

## 📋 Critical Setting

**⚠️ DON'T FORGET:** Set Root Directory to `frontend` in Vercel settings!

## 🔥 That's It!

Your app will be live in 2-3 minutes at `https://your-project.vercel.app`

## 📚 More Details

See [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md) for comprehensive documentation.

---

**Need help?** Check build logs in Vercel dashboard or see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
