"server only"

// Polyfill File constructor for Pinata SDK (needed for JSON uploads)
// Pinata SDK internally uses `new File()` which may not be available in all Node.js environments
if (typeof globalThis.File === 'undefined') {
  // eslint-disable-next-line @typescript-eslint/no-require-imports
  const { File } = require('buffer');
  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  (globalThis as any).File = File;
}

import { PinataSDK } from "pinata"

export const pinata = new PinataSDK({
  pinataJwt: process.env.PINATA_JWT!,
  pinataGateway: "fuchsia-cheap-bat-157.mypinata.cloud"
})
