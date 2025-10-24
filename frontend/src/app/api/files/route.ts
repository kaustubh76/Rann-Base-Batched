import { NextResponse, type NextRequest } from "next/server";
import { pinata } from "@/utils/config"

export async function POST(request: NextRequest) {
  try {
    const data = await request.formData();
    const file = data.get("file");

    // Get form data for JSON metadata
    const name = data.get("name") as string;
    const bio = data.get("bio") as string;
    const life_history = data.get("life_history") as string;
    const adjectives = data.get("adjectives") as string;
    const knowledge_areas = data.get("knowledge_areas") as string;

    if (!file || !(file instanceof Blob)) {
      return NextResponse.json({ error: "No file received" }, { status: 400 });
    }

    // Get file info
    const fileName = (file as any).name || "uploaded-image.jpg";
    const fileSize = file.size;

    console.log("Uploading file to Pinata:", fileName, "(" + (fileSize / 1024 / 1024).toFixed(2) + " MB)");

    // Step 1: Upload image to Pinata IPFS using SDK v3
    // Pinata SDK v3 accepts Blob directly, no need to convert to File
    const imageUpload = await pinata.upload.file(file as File);
    const imageCid = imageUpload.cid;
    console.log("Image uploaded successfully. CID:", imageCid);

    // Step 2: Create JSON metadata
    const metadata = {
      name: name || "Unknown Warrior",
      bio: bio || "A legendary warrior",
      life_history: life_history || "History unknown",
      personality: adjectives ? adjectives.split(', ').map(trait => trait.trim()) : ["Brave", "Skilled"],
      knowledge_areas: knowledge_areas ? knowledge_areas.split(', ').map(area => area.trim()) : ["Combat", "Strategy"],
      image: "ipfs://" + imageCid
    };

    console.log("Created metadata JSON:", metadata);

    // Step 3: Upload JSON metadata to IPFS using SDK v3
    const metadataUpload = await pinata.upload.json(metadata);
    const metadataCid = metadataUpload.cid;
    console.log("Metadata JSON uploaded successfully. CID:", metadataCid);

    // Get the gateway URLs
    const gatewayUrl = process.env.NEXT_PUBLIC_GATEWAY_URL || "https://gateway.pinata.cloud/ipfs/";
    const imageUrl = `${gatewayUrl}${imageCid}`;
    const metadataUrl = `${gatewayUrl}${metadataCid}`;
    
    console.log("=== IPFS UPLOAD COMPLETE ===");
    console.log("Image CID:", imageCid);
    console.log("Image URL:", imageUrl);
    console.log("Metadata CID:", metadataCid);
    console.log("Metadata URL:", metadataUrl);
    console.log("============================");
    
    return NextResponse.json({
      success: true,
      imageCid: imageCid,
      imageUrl: imageUrl,
      metadataCid: metadataCid,
      metadataUrl: metadataUrl,
      metadata: metadata,
      size: fileSize
    }, { status: 200 });
    
  } catch (e) {
    console.error("Error uploading file:", e);
    return NextResponse.json(
      { error: "Internal Server Error" },
      { status: 500 }
    );
  }
}