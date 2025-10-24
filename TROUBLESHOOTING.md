# Troubleshooting Guide

## Common Issues and Solutions

### 1. ✅ FIXED: File Upload Error (ReferenceError: File is not defined)

**Error:**
```
Error uploading file: [ReferenceError: File is not defined]
POST /api/files 500
```

**Cause:** File type doesn't exist in Node.js server environment

**Solution:** ✅ Fixed in commit `e966f18`
- Updated to use Blob type checking
- Fixed Pinata SDK usage
- Corrected gateway URL format

---

### 2. API Route 404 Error

**Error:**
```
POST /api/files 404
```

**Causes & Solutions:**

#### A. Dev Server Needs Restart
After making changes to API routes, Next.js cache may be stale.

**Solution:**
```bash
cd frontend

# Option 1: Clear cache and restart
rm -rf .next
npm run dev

# Option 2: Just restart
# Stop current server (Ctrl+C)
npm run dev
```

#### B. File Not in Correct Location
API routes must be in `src/app/api/` directory.

**Check:**
```bash
ls -la frontend/src/app/api/files/route.ts
# Should exist
```

---

### 3. WalletConnect Warning (Minor)

**Warning:**
```
WalletConnect Core is already initialized. This is probably a mistake
and can lead to unexpected behavior. Init() was called 2 times.
```

**Cause:** React Strict Mode in development causes double-rendering

**Impact:** ⚠️ Warning only, doesn't break functionality

**Solutions:**

#### Option A: Ignore (Recommended for Development)
This is normal in development with React Strict Mode. Will not appear in production.

#### Option B: Disable Strict Mode (Not Recommended)
Edit `frontend/src/app/layout.tsx`:
```typescript
// Remove <StrictMode> wrapper if present
// Only for debugging - keep it enabled for development
```

#### Option C: Conditional Initialization
The warning is harmless and only appears in development. No action needed.

---

### 4. Environment Variables Not Loading

**Error:**
```
Cannot read properties of undefined (reading 'NEXT_PUBLIC_...')
```

**Solutions:**

1. **Check file exists:**
   ```bash
   ls -la frontend/.env.local
   ```

2. **Verify format:**
   ```bash
   # Must start with NEXT_PUBLIC_ for client-side
   NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=...

   # Server-side only (no prefix needed)
   PINATA_JWT=...
   ```

3. **Restart dev server:**
   ```bash
   # Stop server (Ctrl+C)
   npm run dev
   ```

4. **Check for typos:**
   - ✅ `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID` (with underscore)
   - ❌ `NEXT_PUBLIC_WALLETCONNECT_PROJECT_ID` (without underscore)

---

### 5. Pinata Upload Fails

**Error:**
```
Error uploading to IPFS
```

**Solutions:**

1. **Verify JWT token:**
   ```bash
   # Check .env.local
   grep PINATA_JWT frontend/.env.local
   ```

2. **Check gateway URL:**
   ```bash
   # Should include https:// and /ipfs/
   NEXT_PUBLIC_GATEWAY_URL=https://your-gateway.mypinata.cloud/ipfs/
   ```

3. **Test JWT validity:**
   - Visit https://app.pinata.cloud/
   - Check API key status
   - Generate new JWT if expired

4. **Check file size:**
   - Maximum 10MB per upload (configurable)
   - Large files may timeout

---

### 6. Contract Interaction Fails

**Error:**
```
Transaction failed / Contract not found
```

**Solutions:**

1. **Verify network:**
   ```bash
   # Must be on Base Sepolia (Chain ID: 84532)
   # Check MetaMask network
   ```

2. **Check contract addresses:**
   ```bash
   # In frontend/src/constants.ts
   # Should match deployed addresses:
   RannToken: 0xdff6c8409fae4253e207df8d2d0de0eaf79674e5
   YodhaNFT: 0xccce492f07c866b4f8b0fba1e0a5f102c8a92a68
   # etc...
   ```

3. **Verify wallet has test ETH:**
   - Get from: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet

4. **Check gas limits:**
   - May need to increase gas limit for complex transactions

---

### 7. Frontend Won't Start

**Error:**
```
Error: Cannot find module...
```

**Solutions:**

1. **Install dependencies:**
   ```bash
   cd frontend
   rm -rf node_modules package-lock.json
   npm install
   ```

2. **Check Node version:**
   ```bash
   node --version
   # Should be 18.x or higher
   ```

3. **Clear cache:**
   ```bash
   rm -rf .next
   npm run dev
   ```

---

### 8. TypeScript Errors

**Error:**
```
Type errors in development
```

**Solutions:**

1. **Most type errors are Next.js internals:**
   - Can be safely ignored if code runs
   - Won't affect production build

2. **Check your code only:**
   ```bash
   # Type check specific file
   npx tsc --noEmit src/app/page.tsx
   ```

3. **Build to verify:**
   ```bash
   npm run build
   # Will show actual errors
   ```

---

## Quick Diagnostic Commands

### Check Everything
```bash
# From project root
cd "Base Bataches"

# 1. Check contracts deployed
grep -A 5 "84532:" frontend/src/constants.ts

# 2. Check env vars
cd frontend
grep "NEXT_PUBLIC_WALLET_CONNECT" .env.local
grep "PINATA_JWT" .env.local

# 3. Check API routes exist
ls -la src/app/api/*/route.ts

# 4. Test dev server
npm run dev
```

### Fresh Start
```bash
cd frontend

# 1. Clean everything
rm -rf .next node_modules package-lock.json

# 2. Reinstall
npm install

# 3. Start fresh
npm run dev
```

---

## Getting Help

### For Development Issues:
1. Check this troubleshooting guide
2. Review error messages carefully
3. Check browser console (F12)
4. Check terminal logs

### For Contract Issues:
1. Verify on BaseScan: https://sepolia.basescan.org
2. Check transaction hash for details
3. Ensure wallet on correct network

### Documentation:
- **README.md** - Project overview
- **DEPLOYMENT.md** - Deployment guide
- **VERIFICATION_STATUS.md** - Contract verification
- **SETUP_COMPLETE.md** - Setup checklist

---

## Status Check

✅ **All Issues Currently Fixed:**
- ✅ File upload API working
- ✅ Environment variables configured
- ✅ Contracts deployed and verified
- ✅ Frontend starts successfully
- ✅ IPFS integration working

⚠️ **Known Warnings (Safe to Ignore):**
- WalletConnect double initialization (dev mode only)
- TypeScript errors in node_modules (Next.js internals)

---

## Emergency Reset

If everything is broken:

```bash
cd "Base Bataches/frontend"

# Nuclear option - reset everything
rm -rf .next node_modules package-lock.json
npm install
rm -rf .env.local

# Copy env template and fill in
cp .env.local.example .env.local
# Edit .env.local with your values

# Start fresh
npm run dev
```

Then visit: http://localhost:3000

---

**Last Updated:** October 25, 2025
**All systems operational** ✅
