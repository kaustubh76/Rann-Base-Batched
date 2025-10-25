# ⚠️ CRITICAL: How to Set Root Directory in Vercel

## The Problem

Your repository has this structure:
```
Rann-Base-Batched/
├── frontend/          ← Your Next.js app is HERE
│   ├── src/
│   ├── package.json
│   └── next.config.ts
├── src/               ← Solidity contracts
└── test/
```

Vercel needs to know your Next.js app is in the `frontend` folder!

## Step-by-Step Fix

### Option 1: Set During Initial Import (RECOMMENDED)

1. **Go to:** https://vercel.com/new
2. **Click:** "Import" on your GitHub repository
3. **BEFORE clicking Deploy**, look for "Root Directory"
4. **Click:** The "Edit" button next to "Root Directory"
5. **Type:** `frontend`
6. **Click:** "Continue" or "Deploy"

### Option 2: Fix After Failed Deployment

If you already tried to deploy and it failed:

1. **Go to:** Your Vercel dashboard
2. **Click:** Your project name
3. **Click:** "Settings" tab
4. **Click:** "General" in the left sidebar
5. **Scroll to:** "Root Directory"
6. **Click:** "Edit"
7. **Type:** `frontend`
8. **Click:** "Save"
9. **Go back to** "Deployments" tab
10. **Click:** "Redeploy" on the latest deployment

## Visual Guide

### What You Should See:

When importing your project, you'll see a configuration screen with:

```
Configure Project
├─ Project Name: [your-project-name]
├─ Framework Preset: Next.js (Auto-detected)
├─ Root Directory: ./  ← THIS IS WRONG!
│  └─ [Edit] ← CLICK HERE
└─ Build and Output Settings
```

### After Clicking "Edit":

```
Root Directory
┌────────────────────────────────┐
│ frontend                       │  ← TYPE THIS
└────────────────────────────────┘
[Cancel] [Save]
```

## Common Mistakes to Avoid

❌ **Don't type:** `./frontend`
❌ **Don't type:** `/frontend`
❌ **Don't type:** `frontend/`
✅ **DO type:** `frontend`

## How to Verify It's Set Correctly

After setting the root directory, Vercel should:
1. Auto-detect Next.js framework ✅
2. Show build command: `npm run build` ✅
3. Show output directory: `.next` ✅
4. Show install command: `npm install` ✅

## If It Still Fails

Check the error message:
- If you see: `cd: frontend: No such file or directory`
  → Root directory is NOT set correctly

- If you see: `Failed to compile` with TypeScript errors
  → Root directory IS set correctly, but there's a code issue
  (See environment variables section below)

## After Setting Root Directory

Once root directory is set correctly and deployment succeeds, you MUST add environment variables:

1. **Go to:** Settings → Environment Variables
2. **Add each variable** from the list in DEPLOY_NOW.md
3. **Select:** Production, Preview, and Development for EACH variable
4. **Click:** Save after each variable
5. **Go to:** Deployments tab
6. **Click:** Redeploy

## Quick Test

Your deployment is configured correctly if:
- ✅ Build starts without "No such file or directory" error
- ✅ Next.js is detected
- ✅ Dependencies install successfully
- ✅ Build completes (may need env vars)

## Need More Help?

- Check Vercel's official docs: https://vercel.com/docs/projects/overview#root-directory
- See our detailed guide: [VERCEL_DEPLOYMENT.md](./VERCEL_DEPLOYMENT.md)
- Check troubleshooting: [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
