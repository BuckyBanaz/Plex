// file: src/utils/testAwsIdentity.ts
import AWS from "aws-sdk";
import fs from "fs";
import path from "path";

export async function testAwsIdentity() {
  try {
    // ✅ Correct path (one folder deeper)
    const configPath = path.join(__dirname, "src", "config", "config.json");
    const config = JSON.parse(fs.readFileSync(configPath, "utf-8"));

    const sts = new AWS.STS({
      region: config.AWS_REGION,
      accessKeyId: config.AWS_ACCESS_KEY_ID,
      secretAccessKey: config.AWS_SECRET_ACCESS_KEY,
    });

    console.log("🚀 [AWS Identity Test] Checking IAM identity...");

    const data = await sts.getCallerIdentity().promise();

    console.log("✅ [AWS Identity Test] Using credentials for:");
    console.log(`   ARN: ${data.Arn}`);
    console.log(`   Account: ${data.Account}`);
    console.log(`   UserId: ${data.UserId}`);

    return data;
  } catch (err: any) {
    console.error("❌ [AWS Identity Test] Error:", err.message || err);
    throw err;
  }
}
