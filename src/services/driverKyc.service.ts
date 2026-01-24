import AWS from "aws-sdk";
import fs from "fs";
import path from "path";
import { Kyc } from "../models/driverKyc.model";
import Vehicle from "../models/vehicle.model";
import logger from "../utils/logger";
import type { Textract as TextractTypes } from "aws-sdk";
import type { Request } from "express";

const config = JSON.parse(
  fs.readFileSync(path.join(__dirname, "../config/config.json"), "utf-8")
);

//  Strongly typed Textract client with timeout
const textract = new AWS.Textract({
  region: config.AWS_REGION!,
  accessKeyId: config.AWS_ACCESS_KEY_ID!,
  secretAccessKey: config.AWS_SECRET_ACCESS_KEY!,
  httpOptions: { timeout: 20000 },
});

interface KycInput {
  driverId: number;
  files: { [fieldname: string]: Express.Multer.File[] };
  licenseNumber?: string;
  idCardNumber?: string;
  rcNumber?: string;
}

// ✅ Use Express generics for body typing (fixes interface error)
type DriverVehicleBody = {
  ownerName?: string;
  registeringAuthority?: string;
  vehicleType?: string;
  fuelType?: string;
  vehicleAge?: number | string;
};

// ✅ Extend request inline, not via interface
type DriverVehicleRequest = Request<{}, any, DriverVehicleBody> & {
  file?: Express.Multer.File & { location?: string };
};

function normalizeExtractedText(raw: string) {
  const text = raw.replace(/\s+/g, " ").trim();

  return {
    // License fields
    licenseNumber: text.match(/RJ\d+[A-Z0-9]+/)?.[0] || null,
    dob:
      text.match(
        /(0[1-9]|[12][0-9]|3[01])[\/\-\.](0[1-9]|1[0-2])[\/\-\.](19|20)\d\d/
      )?.[0] || null,
    issueDate:
      text.match(
        /(0[1-9]|[12][0-9]|3[01])[\/\-\.](0[1-9]|1[0-2])[\/\-\.](19|20)\d\d/
      )?.[1] || null,
    validTill:
      text.match(
        /(0[1-9]|[12][0-9]|3[01])[\/\-\.](0[1-9]|1[0-2])[\/\-\.](19|20)\d\d/
      )?.[2] || null,
    name: text.match(/Name\s+([A-Z ]+)/i)?.[1]?.trim() || null,
    fatherName:
      text.match(/Son\/Daughter\/Wife of\s+([A-Z ]+)/i)?.[1]?.trim() || null,

    // Aadhaar fields
    aadhaarNumber: text.match(/\b\d{4}\s?\d{4}\s?\d{4}\b/)?.[0] || null,
    gender: text.match(/MALE|FEMALE|TRANSGENDER/i)?.[0] || null,
    mobile: text.match(/(\b[6-9]\d{9}\b)/)?.[0] || null,

    // RC fields
    regNumber: text.match(/RJ[0-9A-Z]{6,}/i)?.[0] || null,
    engineNumber: text.match(/Engine No\.?\s*([A-Z0-9]+)/i)?.[1] || null,
    chassisNumber: text.match(/Chassis No\.?\s*([A-Z0-9]+)/i)?.[1] || null,
    fuelType: text.match(/PETROL|DIESEL|ELECTRIC|CNG/i)?.[0] || null,
    ownerName: text.match(/Owner Name\s*([A-Z ]+)/i)?.[1]?.trim() || null,
  };
}

export async function processDriverKyc(input: KycInput) {
  const { driverId, files, licenseNumber, idCardNumber, rcNumber } = input;

  console.log("input ===========> ", input);

  const licenseUrl = files.licenseImage?.[0]?.location!;
  console.log("licenseUrl ========> ", licenseUrl)
  const idCardUrl = files.idCardImage?.[0]?.location!;
  console.log("idCardUrl ========> ", idCardUrl)
  const rcUrl = files.rcImage?.[0]?.location!;
  console.log("rcUrl ========> ", rcUrl)
  const driverUrl = files.driverImage?.[0]?.location!;
  console.log("driverUrl ========> ", driverUrl)

  if (!licenseUrl || !idCardUrl || !rcUrl || !driverUrl) {
    throw new Error("Missing one or more document uploads (S3 URLs not found)");
  }

  // OCR Helper (now fully typed)
const extractText = async (s3Url: string): Promise<string> => {
  try {
    const bucket = config.S3_BUCKET_NAME!;
    const url = new URL(s3Url);
    const key = decodeURIComponent(url.pathname.substring(1)); //  decode the key

    logger.info(`🔍 Running Textract on: Bucket=${bucket}, Key=${key}`);

    const params: TextractTypes.DetectDocumentTextRequest = {
      Document: { S3Object: { Bucket: bucket, Name: key } },
    };

    // Timeout wrapper (max 10s)
    const textractPromise = textract.detectDocumentText(params).promise();
    const timeoutPromise = new Promise((_, reject) =>
      setTimeout(() => reject(new Error("Textract timeout")), 10000)
    );

    const result = (await Promise.race([textractPromise, timeoutPromise])) as
      | TextractTypes.DetectDocumentTextResponse
      | undefined;

    if (!result || !result.Blocks) {
      logger.warn(`⚠️ Empty OCR result for ${key}`);
      return "";
    }

    logger.info(`✅ Textract success for ${key}`);

    const text = result.Blocks
      .filter((b: TextractTypes.Block) => b.BlockType === "LINE")
      .map((b: TextractTypes.Block) => b.Text)
      .join(" ");

    return text || "";
  } catch (error: any) {
    logger.error(`❌ Textract error for ${s3Url}: ${error.message}`);
    return "";
  }
};

  // Process all OCR calls in parallel
  const [licenseText, idCardText, rcText] = await Promise.all([
    extractText(licenseUrl).then((res) => {
      logger.info(` License OCR done for driver ${driverId}`);
      return res;
    }),
    extractText(idCardUrl).then((res) => {
      logger.info(` ID Card OCR done for driver ${driverId}`);
      return res;
    }),
    extractText(rcUrl).then((res) => {
      logger.info(` RC OCR done for driver ${driverId}`);
      return res;
    }),
  ]);

  const licenseValid = !!licenseNumber && licenseText.includes(licenseNumber);
  const idCardValid = !!idCardNumber && idCardText.includes(idCardNumber);
  const rcValid = !!rcNumber && rcText.includes(rcNumber);

  const kyc = await Kyc.create({
    driverId,
    licenseUrl,
    licenseNumber,
    idCardUrl,
    idCardNumber,
    rcUrl,
    rcNumber,
    driverUrl,
    licenseValid,
    idCardValid,
    rcValid,
    verifiedStatus:
      licenseValid && idCardValid && rcValid ? "verified" : "pending",
  });

  const kycId = kyc.get("id") as number;

  return {
    kycId,
    driverId,
    images: { licenseUrl, idCardUrl, rcUrl, driverUrl },
extractedText: {
  license: normalizeExtractedText(licenseText),
  idCard: normalizeExtractedText(idCardText),
  rc: normalizeExtractedText(rcText),
},
rawText: {
  license: licenseText,
  idCard: idCardText,
  rc: rcText
},
    validation: { licenseValid, idCardValid, rcValid },
  };
}

//  Admin updates KYC status
export async function setKycStatus(
  kycId: number,
  status: "verified" | "rejected"
) {
  const kyc = await Kyc.findByPk(kycId);
  if (!kyc) throw new Error("KYC record not found");

  kyc.set({ verifiedStatus: status });
  await kyc.save();

  // Auto-create vehicle only when KYC is verified
  if (status === "verified") {
    try {
      const driverId = kyc.get("driverId") as number;
      const licenseNumber = kyc.get("licenseNumber") as string | null;

      const existingVehicle = await Vehicle.findOne({ where: { driverId } });
      if (!existingVehicle) {
        await Vehicle.create({
          driverId,
          type: "Unknown",
          licenseNo: licenseNumber || "N/A",
        });
        logger.info(` Vehicle created for driverId: ${driverId}`);
      } else {
        logger.info(` Vehicle already exists for driverId: ${driverId}`);
      }
    } catch (err: any) {
      logger.error(" Error creating vehicle after KYC verification:", err);
    }
  }

  return kyc;
}


/**
 * DRIVER — Add/Update Vehicle Details
 * Sets KYC status → awaiting_approval
 * Returns KYC documents + vehicle details
 */
export async function addOrUpdateDriverVehicleService(req: DriverVehicleRequest, driverId: number) {
  const {
    ownerName,
    registeringAuthority,
    vehicleType,
    fuelType,
    vehicleAge,
  } = req.body;

  const vehicleImageUrl = (req.file as any)?.location || null;

  const kyc = await Kyc.findOne({ where: { driverId } });
  if (!kyc) throw new Error("KYC record not found for this driver.");

  let vehicle = await Vehicle.findOne({ where: { driverId } });

  if (!vehicle) {
    vehicle = await Vehicle.create({
      driverId,
      type: vehicleType || "Unknown",
      licenseNo: kyc.licenseNumber || "N/A",
      ownerName,
      registeringAuthority,
      vehicleType,
      fuelType,
      vehicleAge: vehicleAge ? Number(vehicleAge) : undefined,
      vehicleStatus: "inactive",
      vehicleImageUrl,
    });
  } else {
    await vehicle.update({
      ownerName,
      registeringAuthority,
      vehicleType,
      fuelType,
      vehicleAge: vehicleAge ? Number(vehicleAge) : undefined,
      vehicleImageUrl,
    });
  }

  if (kyc.verifiedStatus === "pending") {
    await kyc.update({ verifiedStatus: "awaiting_approval" as any });
    logger.info(`Driver ${driverId} status → awaiting_approval`);
  }

  return {
    driverId,
    vehicle: {
      id: vehicle.id,
      driverId: vehicle.driverId,
      ownerName: vehicle.ownerName,
      registeringAuthority: vehicle.registeringAuthority,
      vehicleType: vehicle.vehicleType,
      fuelType: vehicle.fuelType,
      vehicleAge: vehicle.vehicleAge,
      vehicleStatus: vehicle.vehicleStatus,
      vehicleImageUrl: vehicle.vehicleImageUrl,
    },
    documents: {
      licenseUrl: kyc.licenseUrl,
      idCardUrl: kyc.idCardUrl,
      rcUrl: kyc.rcUrl,
      driverUrl: kyc.driverUrl,
      vehicle: vehicle.vehicleImageUrl,
    },
    kycStatus: kyc.verifiedStatus,
  };
}

/**
 * ADMIN — Approve or Reject Driver
 */
export async function updateDriverApprovalService(
  driverId: number,
  status: "verified" | "rejected"
) {
  const kyc = await Kyc.findOne({ where: { driverId } });
  if (!kyc) throw new Error("KYC not found for this driver.");

  const vehicle = await Vehicle.findOne({ where: { driverId } });
  if (!vehicle) throw new Error("Vehicle not found for this driver.");

  await kyc.update({ verifiedStatus: status });
  await vehicle.update({
    vehicleStatus: status === "verified" ? "active" : "inactive",
  });

  return {
    driverId,
    vehicle,
    documents: {
      licenseUrl: kyc.licenseUrl,
      idCardUrl: kyc.idCardUrl,
      rcUrl: kyc.rcUrl,
      driverUrl: kyc.driverUrl,
    },
    kyc: {
      verifiedStatus: kyc.verifiedStatus,
    },
  };
}

export async function getDriverStatusService(driverId: number) {
  const kyc = await Kyc.findOne({ where: { driverId } });
  const vehicle = await Vehicle.findOne({ where: { driverId } });

  return {
    driverId,
    kycStatus: kyc?.verifiedStatus || "not_submitted",
    vehicleStatus: vehicle?.vehicleStatus || "not_submitted",
    isVerified: kyc?.verifiedStatus === "verified" && vehicle?.vehicleStatus === "active",
  };
}