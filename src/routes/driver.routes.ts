import { Router } from "express";
import { verifyDriverKYC, driverAddVehicleDetails, updateDriverApprovalStatus, getDriverStatus } from "../controllers/driverKyc.controller";
import { authMiddleware, adminMiddleware } from "../middleware/auth.middleware";
import { upload } from "../middleware/upload.middleware";

const router = Router();

/**
 * @swagger
 * /driver/kyc:
 *   post:
 *     summary: Upload and verify driver KYC documents
 *     tags:
 *       - Driver KYC
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             required:
 *               - licenseImage
 *               - idCardImage
 *               - rcImage
 *               - driverImage
 *             properties:
 *               licenseNumber:
 *                 type: string
 *               idCardNumber:
 *                 type: string
 *               rcNumber:
 *                 type: string
 *               licenseImage:
 *                 type: string
 *                 format: binary
 *               idCardImage:
 *                 type: string
 *                 format: binary
 *               rcImage:
 *                 type: string
 *                 format: binary
 *               driverImage:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: KYC verification completed
 */
router.post(
  "/driver/kyc",
  authMiddleware(),
  upload.fields([
    { name: "licenseImage", maxCount: 1 },
    { name: "idCardImage", maxCount: 1 },
    { name: "rcImage", maxCount: 1 },
    { name: "driverImage", maxCount: 1 },
  ]),
  verifyDriverKYC
);

/**
 * @swagger
 * /driver/vehicle-details:
 *   post:
 *     summary: Submit driver vehicle details
 *     tags:
 *       - Driver KYC
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               ownerName:
 *                 type: string
 *               registeringAuthority:
 *                 type: string
 *               vehicleType:
 *                 type: string
 *               fuelType:
 *                 type: string
 *               vehicleAge:
 *                 type: number
 *               vehicleImage:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Vehicle details submitted
 */
router.post(
  "/driver/vehicle-details",
  authMiddleware(),
  upload.single("vehicleImage"),
  driverAddVehicleDetails
);

/**
 * @swagger
 * /admin/driver/{driverId}/status:
 *   put:
 *     summary: Admin verifies or rejects driver
 *     tags:
 *       - Admin
 *     parameters:
 *       - in: path
 *         name: driverId
 *         required: true
 *         schema:
 *           type: integer
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               status:
 *                 type: string
 *                 enum:
 *                   - verified
 *                   - rejected
 *     responses:
 *       200:
 *         description: Driver status updated
 */
router.put(
  "/admin/driver/:driverId/status",
  adminMiddleware,
  updateDriverApprovalStatus
);


/**
 * @swagger
 * /driver/status:
 *   get:
 *     summary: Get driver KYC and vehicle verification status
 *     tags:
 *       - Driver KYC
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Driver status fetched
 */
router.get(
  "/driver/status",
  authMiddleware(),
  getDriverStatus
);

export default router;
