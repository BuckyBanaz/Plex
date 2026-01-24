import { Router } from "express";
import { ShipmentController } from "../controllers/shipment.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { upload } from "../middleware/upload.middleware";

const router = Router();
const controller = new ShipmentController();

/**
 * @swagger
 * tags:
 *   name: Shipment
 *   description: APIs for managing shipments, payments, and live tracking
 */

/**
 * @swagger
 * /shipments/estimate:
 *   post:
 *     summary: Estimate shipment cost using Google Distance Matrix API
 *     tags: [Shipment]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Authentication token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - originLat
 *               - originLng
 *               - destinationLat
 *               - destinationLng
 *               - weight
 *             properties:
 *               originLat:
 *                 type: number
 *                 example: 28.7935
 *               originLng:
 *                 type: number
 *                 example: 75.9894
 *               destinationLat:
 *                 type: number
 *                 example: 28.8943
 *               destinationLng:
 *                 type: number
 *                 example: 76.6066
 *               weight:
 *                 type: number
 *                 example: 2.5
 *     responses:
 *       200:
 *         description: Estimated cost and distance calculated successfully
 */
router.post("/estimate", authMiddleware(), controller.estimate.bind(controller));

/**
 * @swagger
 * /shipments/create:
 *   post:
 *     summary: Create a new shipment and initialize Stripe PaymentIntent
 *     tags: [Shipment]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Authentication token
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - userId
 *               - vehicleType
 *               - pickup
 *               - dropoff
 *               - weight
 *               - paymentMethod
 *             properties:
 *               userId:
 *                 type: number
 *                 example: 8
 *               vehicleType:
 *                 type: string
 *                 example: "Bike"
 *               images:
 *                 type: array
 *                 items:
 *                   type: string
 *                 example:
 *                   - "https://example.com/uploads/pickup1.jpg"
 *                   - "https://example.com/uploads/pickup2.jpg"
 *               collectTime:
 *                 type: object
 *                 properties:
 *                   type:
 *                     type: string
 *                     enum: [immediate, scheduled]
 *                     example: "scheduled"
 *                   scheduledAt:
 *                     type: string
 *                     example: "2025-11-03T17:30:00Z"
 *               weight:
 *                 type: string
 *                 example: "2.5 kg"
 *               notes:
 *                 type: string
 *                 example: "Handle with care. Deliver before 6 PM."
 *               pickup:
 *                 type: object
 *                 properties:
 *                   name:
 *                     type: string
 *                     example: "Parikshit Verma"
 *                   phone:
 *                     type: string
 *                     example: "+918901414107"
 *                   address:
 *                     type: string
 *                     example: "123 MG Road, Bhiwani, Haryana, India"
 *                   latitude:
 *                     type: number
 *                     example: 28.7935
 *                   longitude:
 *                     type: number
 *                     example: 75.9894
 *               dropoff:
 *                 type: object
 *                 properties:
 *                   name:
 *                     type: string
 *                     example: "Amit Sharma"
 *                   phone:
 *                     type: string
 *                     example: "+918765432100"
 *                   address:
 *                     type: string
 *                     example: "45 Nehru Colony, Rohtak, Haryana, India"
 *                   latitude:
 *                     type: number
 *                     example: 28.8943
 *                   longitude:
 *                     type: number
 *                     example: 76.6066
 *               paymentMethod:
 *                 type: string
 *                 example: "stripe"
 *     responses:
 *       201:
 *         description: Shipment created successfully with Stripe PaymentIntent
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "Shipment created with Stripe payment"
 *                 shipment:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: number
 *                       example: 101
 *                     orderId:
 *                       type: string
 *                       example: "ORD-1730738257712-2345"
 *                     invoiceNumber:
 *                       type: string
 *                       example: "INV-202511-4821"
 *                     userId:
 *                       type: number
 *                       example: 8
 *                     vehicleType:
 *                       type: string
 *                       example: "Bike"
 *                     status:
 *                       type: string
 *                       example: "created"
 *                     paymentStatus:
 *                       type: string
 *                       example: "pending"
 *                     paymentMethod:
 *                       type: string
 *                       example: "stripe"
 *                     weight:
 *                       type: string
 *                       example: "2.5 kg"
 *                     notes:
 *                       type: string
 *                       example: "Handle with care. Deliver before 6 PM."
 *                 clientSecret:
 *                   type: string
 *                   example: "pi_3SNZEN6j6LVPNcUm0g8zDlav_secret_ks2ajYhVrCLq4WnMbAeLcshZ0"
 *                 estimate:
 *                   type: object
 *                   properties:
 *                     distanceKm:
 *                       type: number
 *                       example: 1366.57
 *                     durationText:
 *                       type: string
 *                       example: "23 hours 15 mins"
 *                     estimatedCostINR:
 *                       type: number
 *                       example: 13765.68
 *                     estimatedCostUSD:
 *                       type: number
 *                       example: 165.19
 *                     currency:
 *                       type: string
 *                       example: "USD"
 */
router.post("/create", authMiddleware(), upload.array("images", 5), controller.createShipment.bind(controller));


/**
 * @swagger
 * /shipments/confirm-payment:
 *   post:
 *     summary: Confirm Stripe payment for a shipment
 *     tags: [Shipment]
 *     parameters:
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
 *             required:
 *               - shipmentId
 *               - paymentIntentId
 *               - paymentStatus
 *             properties:
 *               shipmentId:
 *                 type: number
 *                 example: 5
 *               paymentIntentId:
 *                 type: string
 *                 example: "pi_3Qdxyz12345"
 *               paymentStatus:
 *                 type: string
 *                 example: "succeeded"
 *     responses:
 *       200:
 *         description: Payment confirmed successfully
 */
router.post("/confirm-payment", authMiddleware(), controller.confirmPayment.bind(controller));

/**
 * @swagger
 * /shipments/{id}/location:
 *   post:
 *     summary: Update driver's live GPS location
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
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
 *             required:
 *               - lat
 *               - lng
 *             properties:
 *               lat:
 *                 type: number
 *                 example: 28.7041
 *               lng:
 *                 type: number
 *                 example: 77.1025
 *     responses:
 *       200:
 *         description: Location updated successfully
 */
router.post("/:id/location", authMiddleware(), controller.updateLocation.bind(controller));

/**
 * @swagger
 * /shipments/{id}/accept:
 *   post:
 *     summary: Driver accepts a shipment
 *     description: Allows an authenticated driver to accept a shipment. The driver must have an assigned vehicle.
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *         description: Shipment ID to be accepted
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Authentication token of the driver
 *     responses:
 *       200:
 *         description: Shipment accepted successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 shipment:
 *                   type: object
 *                   properties:
 *                     id:
 *                       type: integer
 *                       example: 1
 *                     driverId:
 *                       type: integer
 *                       example: 5
 *                     vehicleId:
 *                       type: integer
 *                       example: 2
 *                     driverDetails:
 *                       type: object
 *                       properties:
 *                         name:
 *                           type: string
 *                           example: "Driver-5"
 *                         phone:
 *                           type: string
 *                           example: "9999999999"
 *                     status:
 *                       type: string
 *                       example: "in_transit"
 *       400:
 *         description: Bad request (e.g., driver has no vehicle)
 *       401:
 *         description: Unauthorized (missing or invalid token)
 *       404:
 *         description: Shipment not found
 *       500:
 *         description: Internal server error
 */

//  Route: Driver accepts a shipment
router.post("/:id/accept", authMiddleware(), controller.acceptShipment.bind(controller));

/**
 * @swagger
 * /shipments/{id}/location:
 *   get:
 *     summary: Get current shipment GPS location
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Current location retrieved successfully
 */
router.get("/:id/location", authMiddleware(), controller.getLocation.bind(controller));

/**
 * @swagger
 * /shipments/{id}/deliver:
 *   post:
 *     summary: Driver marks shipment as delivered
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Shipment delivery confirmed and user notified
 */
router.post("/:id/deliver", authMiddleware(), controller.deliverShipment.bind(controller));



/**
 * @swagger
 * /shipments:
 *   get:
 *     summary: Get all shipments for logged-in user
 *     tags: [Shipment]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: List of shipments retrieved successfully
 */
router.get("/", authMiddleware(), controller.getAllShipments.bind(controller));

/**
 * @swagger
 * /shipments/{id}:
 *   get:
 *     summary: Get shipment details by ID
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Shipment details retrieved successfully
 */
router.get("/:id", authMiddleware(), controller.getShipmentById.bind(controller));

/**
 * @swagger
 * /shipments/{id}:
 *   put:
 *     summary: Update shipment details
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       required: false
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               weight:
 *                 type: string
 *                 example: "3 kg"
 *               notes:
 *                 type: string
 *                 example: "Update: fragile item"
 *     responses:
 *       200:
 *         description: Shipment updated successfully
 */
router.put("/:id", authMiddleware(), controller.updateShipment.bind(controller));

/**
 * @swagger
 * /shipments/{id}:
 *   delete:
 *     summary: Delete shipment by ID
 *     tags: [Shipment]
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: integer
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Shipment deleted successfully
 */
router.delete("/:id", authMiddleware(), controller.deleteShipment.bind(controller));

/**
 * @swagger
 * /shipments/confirm-stripe:
 *   post:
 *     summary: Confirm Stripe PaymentIntent directly from backend
 *     tags: [Shipment]
 *     description: Confirms a Stripe PaymentIntent securely using server-side secret key.
 *     parameters:
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
 *             required:
 *               - paymentIntentId
 *             properties:
 *               paymentIntentId:
 *                 type: string
 *                 example: "pi_3SQWBM6j6LVPNcUm1gl84DLT"
 *               payment_method:
 *                 type: string
 *                 example: "pm_card_visa"
 *               return_url:
 *                 type: string
 *                 example: "https://localhost:3000/success"
 *     responses:
 *       200:
 *         description: Stripe PaymentIntent confirmed successfully
 */
router.post(
  "/confirm-stripe",
  authMiddleware(),
  controller.confirmStripePayment.bind(controller)
);

/**
 * @swagger
 * /shipments/driver/notifications:
 *   get:
 *     summary: Get new shipment notifications for the driver
 *     description: Returns shipments that are paid, assigned, and waiting for driver acceptance.
 *     tags: [Shipment]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Driver authentication token
 *     responses:
 *       200:
 *         description: List of shipments available for driver acceptance
 */
router.get(
  "/driver/notifications",
  authMiddleware(),
  controller.getDriverNotifications.bind(controller)
);

/**
 * @swagger
 * /shipments/driver/active:
 *   get:
 *     summary: Get active shipments assigned to the driver
 *     description: Returns shipments where driver has accepted and status is assigned/in_transit/picked_up.
 *     tags: [Shipment]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: Driver authentication token
 *     responses:
 *       200:
 *         description: Active shipments fetched successfully
 */
router.get(
  "/driver/active",
  authMiddleware(),
  controller.getDriverActiveShipments.bind(controller)
);


/**
 * @swagger
 * /shipments/user/notifications:
 *   get:
 *     summary: Get all shipment notifications for the user
 *     description: Returns entire shipment history in a notification format for the logged-in user.
 *     tags: [Shipment]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         schema:
 *           type: string
 *         description: User authentication token
 *     responses:
 *       200:
 *         description: User shipment notifications returned successfully
 */
router.get(
  "/user/notifications",
  authMiddleware(),
  controller.getUserNotifications.bind(controller)
);



export default router;
