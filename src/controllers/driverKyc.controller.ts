import { Request, Response } from "express";
import { processDriverKyc, setKycStatus, addOrUpdateDriverVehicleService, updateDriverApprovalService, getDriverStatusService } from "../services/driverKyc.service";
import logger from "../utils/logger";
import fs from "fs";


const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

// POST /driver/kyc
export async function verifyDriverKYC(req: Request, res: Response) {
    console.log("🚀 Reached verifyDriverKYC controller");
  try {
    console.log("=============> ")
    const driverId = (req as any).user.id; 
    console.log("driverId ==========> ", driverId);
    const lang_id = req.headers.lang_id as string;
    console.log("lang_id ==========> ", lang_id)
    const { licenseNumber, idCardNumber, rcNumber } = req.body;
        console.log("body =========> ", req.body);
    const files = req.files as { [fieldname: string]: Express.Multer.File[] };
        console.log("files =========> ", files);



    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!files || !files.licenseImage || !files.idCardImage || !files.rcImage || !files.driverImage) {
      return res.status(400).json({ success: false, message: "All document images are required" });
    }

    const result = await processDriverKyc({
      driverId,
      files,
      licenseNumber,
      idCardNumber,
      rcNumber,
    });

    console.log("result ===========> ", result);

    return res.status(200).json({
      success: true,
      message: "KYC verification completed",
      data: result,
    });
  } catch (error: any) {
    logger.error("KYC verification error:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
}

// -------------------------------
// POST /driver/vehicle-details
// -------------------------------
export async function driverAddVehicleDetails(req: Request, res: Response) {
  try {
    const driverId = (req as any).user.id;
    const lang_id = req.headers.lang_id as string;
        if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });
    const result = await addOrUpdateDriverVehicleService(req, driverId);

    return res.status(200).json({
      success: true,
      message:
        "Vehicle details submitted successfully and sent for admin approval.",
      data: result,
    });
  } catch (error: any) {
    logger.error("Error adding driver vehicle details:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
}

// -------------------------------
// PUT /admin/driver/:driverId/status
// -------------------------------
export async function updateDriverApprovalStatus(req: Request, res: Response) {
  try {
    const { driverId } = req.params;
    const { status } = req.body; // verified | rejected

    const result = await updateDriverApprovalService(Number(driverId), status);

    return res.status(200).json({
      success: true,
      message:
        status === "verified"
          ? "Driver verified successfully."
          : "Driver verification rejected.",
      data: result,
    });
  } catch (error: any) {
    logger.error("Error updating driver approval status:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
}

// PATCH /admin/driver/kyc/:id/status
export async function updateKycStatus(req: Request, res: Response) {
  try {
    const { id } = req.params;
    const { status } = req.body;
    const lang_id = req.headers.lang_id as string;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    const updated = await setKycStatus(Number(id), status);
    return res.status(200).json({
      success: true,
      message: `KYC status updated to ${status}`,
      data: updated,
    });
  } catch (error: any) {
    logger.error("Error updating KYC status:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
}

export async function getDriverStatus(req: Request, res: Response) {
  try {
    const driverId = (req as any).user.id;
    const lang_id = req.headers.lang_id as string;

    if (!lang_id)
      return res.status(400).json({ success: false, message: "lang_id header is required" });

    if (lang_id !== config.LANG_ID_ENG)
      return res.status(400).json({ success: false, message: "Invalid lang_id" });

    const result = await getDriverStatusService(driverId);

    return res.status(200).json({
      success: true,
      message: "Driver status fetched successfully",
      data: result,
    });

  } catch (error: any) {
    logger.error("Error fetching driver status:", error);
    return res.status(500).json({ success: false, message: error.message });
  }
}
