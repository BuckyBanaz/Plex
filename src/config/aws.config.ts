import { S3Client } from "@aws-sdk/client-s3";
import fs from "fs";
import path from "path";

const configPath = path.join(__dirname, "../config/config.json");
const config = JSON.parse(fs.readFileSync(configPath, "utf-8"));

const region = config.AWS_REGION || "ap-south-1";
// console.log("region =========> ", region)
const credentials = {
  accessKeyId: config.AWS_ACCESS_KEY_ID,
  secretAccessKey: config.AWS_SECRET_ACCESS_KEY,
};
// console.log("credentials ==========> ", credentials)

export const s3 = new S3Client({
  region,
  credentials,
});

// console.log("s3 ========> ", s3)

export const S3_BUCKET_NAME = config.S3_BUCKET_NAME || "";
