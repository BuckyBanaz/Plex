import { Router } from 'express';
import ServiceTypeController from '../controllers/serviceType.controller';

const router = Router();

/**
 * @swagger
 * tags:
 *   name: ServiceTypes
 *   description: Service Type management APIs
 */

/**
 * @swagger
 * /service-types:
 *   post:
 *     summary: Create a new service type
 *     tags: [ServiceTypes]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *             properties:
 *               name:
 *                 type: string
 *                 description: Name of the service type
 *     responses:
 *       201:
 *         description: Service type created successfully
 *       400:
 *         description: Bad request
 */
router.post('/', ServiceTypeController.create);

/**
 * @swagger
 * /service-types:
 *   get:
 *     summary: Get all service types
 *     tags: [ServiceTypes]
 *     responses:
 *       200:
 *         description: List of service types
 */
router.get('/', ServiceTypeController.getAll);

/**
 * @swagger
 * /service-types/{id}:
 *   get:
 *     summary: Get a service type by ID
 *     tags: [ServiceTypes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Service type details
 *       404:
 *         description: Not found
 */
router.get('/:id', ServiceTypeController.getById);

/**
 * @swagger
 * /service-types/{id}:
 *   put:
 *     summary: Update a service type
 *     tags: [ServiceTypes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *     responses:
 *       200:
 *         description: Service type updated successfully
 *       404:
 *         description: Not found
 */
router.put('/:id', ServiceTypeController.update);

/**
 * @swagger
 * /service-types/{id}:
 *   delete:
 *     summary: Delete a service type
 *     tags: [ServiceTypes]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *     responses:
 *       204:
 *         description: Deleted successfully
 *       404:
 *         description: Not found
 */
router.delete('/:id', ServiceTypeController.delete);

export default router;
