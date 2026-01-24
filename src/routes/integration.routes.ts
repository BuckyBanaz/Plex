import { Router } from 'express';
import { IntegrationController } from '../controllers/integration.controller';

const router = Router();
const controller = new IntegrationController();

/**
 * @swagger
 * tags:
 *   name: Integrations
 *   description: Integration token management APIs
 */

/**
 * @swagger
 * /integration:
 *   post:
 *     summary: Save a new integration token
 *     tags: [Integrations]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               provider:
 *                 type: string
 *               token:
 *                 type: string
 *               expiresAt:
 *                 type: string
 *                 format: date-time
 *     responses:
 *       201:
 *         description: Token saved successfully
 *       400:
 *         description: Invalid input
 */
router.post('/', controller.saveToken.bind(controller));

/**
 * @swagger
 * /integration/{provider}:
 *   get:
 *     summary: Get token by provider
 *     tags: [Integrations]
 *     parameters:
 *       - in: path
 *         name: provider
 *         schema:
 *           type: string
 *         required: true
 *         description: Provider name
 *     responses:
 *       200:
 *         description: Token retrieved successfully
 *       404:
 *         description: Token not found
 */
router.get('/:provider', controller.getToken.bind(controller));

/**
 * @swagger
 * /integration/{provider}:
 *   delete:
 *     summary: Delete token by provider
 *     tags: [Integrations]
 *     parameters:
 *       - in: path
 *         name: provider
 *         schema:
 *           type: string
 *         required: true
 *         description: Provider name
 *     responses:
 *       200:
 *         description: Token deleted successfully
 *       404:
 *         description: Token not found
 */
router.delete('/:provider', controller.deleteToken.bind(controller));

export default router;
