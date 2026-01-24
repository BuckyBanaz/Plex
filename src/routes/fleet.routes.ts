import { Router } from 'express';
import { FleetController } from '../controllers/fleet.controller';

const router = Router();
const controller = new FleetController();

/**
 * @swagger
 * tags:
 *   name: Fleet
 *   description: Vehicle management APIs
 */

/**
 * @swagger
 * /fleet:
 *   post:
 *     summary: Register a new vehicle
 *     tags: [Fleet]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               type:
 *                 type: string
 *               licenseNo:
 *                 type: string
 *               driverId:
 *                 type: integer
 *     responses:
 *       201:
 *         description: Vehicle registered successfully
 *       400:
 *         description: Invalid input
 */
router.post('/', controller.registerVehicle.bind(controller));

/**
 * @swagger
 * /fleet:
 *   get:
 *     summary: Get all vehicles
 *     tags: [Fleet]
 *     responses:
 *       200:
 *         description: List of vehicles
 */
router.get('/', controller.getAllVehicles.bind(controller));

/**
 * @swagger
 * /fleet/{id}:
 *   get:
 *     summary: Get vehicle by ID
 *     tags: [Fleet]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: Vehicle ID
 *     responses:
 *       200:
 *         description: Vehicle details
 *       404:
 *         description: Vehicle not found
 */
router.get('/:id', controller.getVehicleById.bind(controller));

/**
 * @swagger
 * /fleet/{id}:
 *   put:
 *     summary: Update a vehicle
 *     tags: [Fleet]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: Vehicle ID
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               type:
 *                 type: string
 *               licenseNo:
 *                 type: string
 *               driverId:
 *                 type: integer
 *     responses:
 *       200:
 *         description: Vehicle updated successfully
 *       404:
 *         description: Vehicle not found
 */
router.put('/:id', controller.updateVehicle.bind(controller));

/**
 * @swagger
 * /fleet/{id}:
 *   delete:
 *     summary: Delete a vehicle
 *     tags: [Fleet]
 *     parameters:
 *       - in: path
 *         name: id
 *         schema:
 *           type: integer
 *         required: true
 *         description: Vehicle ID
 *     responses:
 *       200:
 *         description: Vehicle deleted successfully
 *       404:
 *         description: Vehicle not found
 */
router.delete('/:id', controller.deleteVehicle.bind(controller));

export default router;
