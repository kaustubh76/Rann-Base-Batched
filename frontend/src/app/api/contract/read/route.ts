import { NextRequest, NextResponse } from 'next/server';
import { createPublicClient, http } from 'viem';
import { Chain } from 'viem';
import { anvil, baseSepolia } from 'viem/chains';

// Define supported chains
const SUPPORTED_CHAINS: Record<number, Chain> = {
  [baseSepolia.id]: baseSepolia, // Chain ID 84532
  [anvil.id]: anvil, // Chain ID 31337
};

export async function POST(request: NextRequest) {
  try {
    const { contractAddress, abi, functionName, args, chainId } = await request.json();

    if (!contractAddress || !abi || !functionName) {
      return NextResponse.json(
        { error: 'Missing required parameters' },
        { status: 400 }
      );
    }

    // Default to Base Sepolia (84532) if no chainId provided
    const targetChainId = chainId || 84532;

    // Get the chain configuration
    const chain = SUPPORTED_CHAINS[targetChainId];
    if (!chain) {
      return NextResponse.json(
        { error: `Unsupported chain ID: ${targetChainId}. Supported chains: ${Object.keys(SUPPORTED_CHAINS).join(', ')}` },
        { status: 400 }
      );
    }

    // Create a public client for reading contract data
    const publicClient = createPublicClient({
      chain: chain,
      transport: http(),
    });

    // Convert string arguments back to appropriate types for contract calls
    let processedArgs = args || [];
    if (args && Array.isArray(args)) {
      processedArgs = args.map((arg: string | number | bigint) => {
        // Convert string numbers back to BigInt for contract calls
        if (typeof arg === 'string' && /^\d+$/.test(arg)) {
          return BigInt(arg);
        }
        return arg;
      });
    }

    console.log('Contract call:', { contractAddress, functionName, args: processedArgs });

    // Read from the contract
    const result = await publicClient.readContract({
      address: contractAddress as `0x${string}`,
      abi: abi,
      functionName: functionName,
      args: processedArgs,
    });

    console.log('Contract result:', result);

    // Convert BigInt results to string for JSON serialization
    const serializedResult = JSON.parse(JSON.stringify(result, (key, value) =>
      typeof value === 'bigint' ? value.toString() : value
    ));

    return NextResponse.json(serializedResult);

  } catch (error) {
    console.error('Contract read error:', error);
    return NextResponse.json(
      { error: 'Failed to read from contract', details: error instanceof Error ? error.message : 'Unknown error' },
      { status: 500 }
    );
  }
}