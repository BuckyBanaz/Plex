import { Request, Response, Router } from "express";
import {
  adminLogin,
  createAdmin
} from "../controllers/admin.controller";

import { adminAuthMiddleware } from "../middleware/adminAuth.middleware";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Admin Authentication
 *   description: Admin login & admin management APIs
 */

/**
 * @swagger
 * /admin/login:
 *   post:
 *     summary: Admin login endpoint
 *     tags: [Admin Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *                 example: "admin@plex.com"
 *               password:
 *                 type: string
 *                 example: "Admin@123"
 *     responses:
 *       200:
 *         description: Admin logged in successfully
 *       401:
 *         description: Invalid credentials
 */
router.post("/admin/login", adminLogin);

/**
 * @swagger
 * /admin/create:
 *   post:
 *     summary: Create a new admin (Only super admin can access)
 *     tags: [Admin Authentication]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *               - role
 *             properties:
 *               name:
 *                 type: string
 *                 example: "KYC Admin"
 *               email:
 *                 type: string
 *                 example: "kycadmin@plex.com"
 *               password:
 *                 type: string
 *                 example: "Password@123"
 *               role:
 *                 type: string
 *                 example: "kyc_admin"
 *     responses:
 *       201:
 *         description: Admin created successfully
 *       403:
 *         description: Unauthorized / Invalid token
 */
router.post("/admin/create", adminAuthMiddleware, createAdmin);

/**
 * @swagger
 * /admin/hello:
 *   get:
 *     summary: Admin test route
 *     tags: [Admin Authentication]
 *     responses:
 *       200:
 *         description: Returns hello
 */
router.get("/admin/hello", (req: Request, res: Response) => {
  res.send("Hello Admin Swagger!");
});

export default router;
