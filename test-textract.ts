// file: test-textract.ts
import AWS from "aws-sdk";
import fs from "fs";
import path from "path";

const configPath = path.join(__dirname, "src", "config", "config.json");
const config = JSON.parse(fs.readFileSync(configPath, "utf-8"));

console.log("config ===========> ", config);

// ✅ Create Textract client
const textract = new AWS.Textract({
  region: config.AWS_REGION!,
  accessKeyId: config.AWS_ACCESS_KEY_ID!,
  secretAccessKey: config.AWS_SECRET_ACCESS_KEY!,
});

/**
 * ✅ This function runs automatically at server startup
 * Checks if AWS Textract and S3 bucket access are working correctly.
 */
export async function testTextractConnection() {
  try {
    console.log("🚀 [Textract Test] Starting connection check...");

    const response = await textract
      .detectDocumentText({
        Document: {
          S3Object: {
            Bucket: "plex-dev-user-image-uploads",
            // 🔹 Replace with an actual file key from your bucket
            Name: "Screenshot-1.png",
          },
        },
      })
      .promise();

    console.log("✅ [Textract Test] Success!");
    console.log("Detected text blocks:", response.Blocks?.length || 0);
    const preview = response.Blocks?.filter((b) => b.BlockType === "LINE")
      .map((b) => b.Text)
      .slice(0, 3)
      .join("\n");
    console.log("🧾 Sample text:\n", preview || "(No text found)");
  } catch (err: any) {
    console.error("❌ [Textract Test] Failed:", err.message || err);
  }
}
