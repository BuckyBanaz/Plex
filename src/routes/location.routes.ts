import { Router } from "express";
import {
  saveLocation,
  getLatestLocation,
  getUserLocations
} from "../controllers/location.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Location
 *   description: User location management APIs
 */

/**
 * @swagger
 * /location:
 *   put:
 *     summary: Save or update user location
 *     tags: [Location]
 *     parameters:
 *        - in: header
 *          name: token
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: api_key
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - latitude
 *               - longitude
 *             properties:
 *               latitude:
 *                 type: number
 *               longitude:
 *                 type: number
 *               accuracy:
 *                 type: number
 *               heading:
 *                 type: number
 *               speed:
 *                 type: number
 *               recorded_at:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       201:
 *         description: Location saved successfully
 *       400:
 *         description: Bad request
 *       401:
 *         description: Unauthorized
 */
router.put("/", authMiddleware(), saveLocation);

/**
 * @swagger
 * /location/latest:
 *   get:
 *     summary: Get latest location of authenticated user
 *     tags: [Location]
 *     parameters:
 *        - in: header
 *          name: token
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: api_key
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     responses:
 *       200:
 *         description: Latest location returned
 *       401:
 *         description: Unauthorized
 *       404:
 *         description: No location found
 */
router.get("/latest", authMiddleware(), getLatestLocation);

/**
 * @swagger
 * /location/{userId}:
 *   get:
 *     summary: Get location history of a user
 *     tags: [Location]
 *     parameters:
 *        - in: header
 *          name: token
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: api_key
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *        - in: path
 *          name: userId
 *          schema:
 *            type: integer
 *          required: true
 *        - in: query
 *          name: limit
 *          schema:
 *            type: integer
 *        - in: query
 *          name: offset
 *          schema:
 *            type: integer
 *        - in: query
 *          name: from
 *          schema:
 *            type: string
 *            format: date-time
 *        - in: query
 *          name: to
 *          schema:
 *            type: string
 *            format: date-time
 *     responses:
 *       200:
 *         description: User locations returned
 *       400:
 *         description: Invalid userId
 *       401:
 *         description: Unauthorized
 */
router.get("/:userId", authMiddleware(), getUserLocations);

export default router;
