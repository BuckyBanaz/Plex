import { Router } from "express";
import {
  addAddress,
  getUserAddresses,
  setDefaultAddress,
  deleteAddress,
} from "../controllers/address.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Address
 *   description: APIs for managing user addresses
 */

/**
 * @swagger
 * /address:
 *   post:
 *     summary: Add a new address for the logged-in user
 *     tags: [Address]
 *     parameters:
 *       - in: header
 *         name: token
 *         description: JWT token for authentication
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         description: Language identifier
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - address
 *               - addressAs
 *               - latitude
 *               - longitude
 *             properties:
 *               address:
 *                 type: string
 *                 example: "123 Main Street"
 *               addressAs:
 *                 type: string
 *                 example: "Home"
 *               landmark:
 *                 type: string
 *                 example: "Near City Mall"
 *               locality:
 *                 type: string
 *                 example: "Vaishali Nagar"
 *               latitude:
 *                 type: number
 *                 example: 26.9124
 *               longitude:
 *                 type: number
 *                 example: 75.7873
 *               isDefault:
 *                 type: boolean
 *                 example: false
 *     responses:
 *       201:
 *         description: Address added successfully
 *       400:
 *         description: Invalid input data
 */
router.post("/", authMiddleware(), addAddress);

/**
 * @swagger
 * /address:
 *   get:
 *     summary: Get all saved addresses for the logged-in user
 *     tags: [Address]
 *     parameters:
 *       - in: header
 *         name: token
 *         description: JWT token for authentication
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         description: Language identifier
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of user addresses
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 count:
 *                   type: integer
 *                   example: 2
 *                 data:
 *                   type: array
 *                   items:
 *                     type: object
 *                     properties:
 *                       id:
 *                         type: integer
 *                         example: 1
 *                       address:
 *                         type: string
 *                         example: "123 Main Street"
 *                       addressAs:
 *                         type: string
 *                         example: "Home"
 *                       isDefault:
 *                         type: boolean
 *                         example: true
 */
router.get("/", authMiddleware(), getUserAddresses);

/**
 * @swagger
 * /address/default/{addressId}:
 *   put:
 *     summary: Set a default address for the user
 *     tags: [Address]
 *     parameters:
 *       - in: header
 *         name: token
 *         description: JWT token for authentication
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         description: Language identifier
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: addressId
 *         description: ID of the address to set as default
 *         required: true
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Default address updated successfully
 *       400:
 *         description: Invalid address ID
 */
router.put("/default/:addressId", authMiddleware(), setDefaultAddress);

/**
 * @swagger
 * /address/{addressId}:
 *   delete:
 *     summary: Delete a specific address
 *     tags: [Address]
 *     parameters:
 *       - in: header
 *         name: token
 *         description: JWT token for authentication
 *         required: true
 *         schema:
 *           type: string
 *       - in: header
 *         name: lang_id
 *         description: Language identifier
 *         required: true
 *         schema:
 *           type: string
 *       - in: path
 *         name: addressId
 *         description: ID of the address to delete
 *         required: true
 *         schema:
 *           type: integer
 *           example: 1
 *     responses:
 *       200:
 *         description: Address deleted successfully
 *       404:
 *         description: Address not found
 */
router.delete("/:addressId", authMiddleware(), deleteAddress);

/**
 * @swagger
 * /address/test:
 *   get:
 *     summary: Test route for address APIs
 *     tags: [Address]
 *     parameters:
 *       - in: header
 *         name: token
 *         description: JWT token for authentication
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Returns Hello Address!
 */
router.get("/test", (req, res) => {
  res.send("Hello Address!");
});

export default router;
