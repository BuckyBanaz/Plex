import { Router } from "express";

import registrationRoutes from "./auth.routes";
import logsRoutes from "./logs.routes";
import fleetRoutes from "./fleet.routes";
import tripRoutes from "./trip.routes";
import serviceTypeRoutes from "./serviceType.routes";
import integrationRoutes from "./integration.routes";
import locatiopnRouites from "./location.routes";
import shipmentRoutes from "./shipment.routes"; // <-- import
import stripeWebhookRoutes from "./stripeWebhook.routes";
import addressRoutes from "./address.routes";
import socketRoutes from "./socket.routes";
import driverKycRoutes from "./driver.routes";
import adminRoutes from "./adminAuth.routes";

const router = Router();

// Auth routes
router.use("/", registrationRoutes);

// Logs download API mounted at /api-logs
router.use("/api-logs", logsRoutes);

// Fleet routes mounted at /fleet
router.use("/fleet", fleetRoutes);

// Trip routes mounted at /trips
router.use("/trips", tripRoutes);

// Service Type routes mounted at /service-types
router.use("/service-types", serviceTypeRoutes);

// Integration token routes mounted at /integration
router.use("/integration", integrationRoutes);

// Location 
router.use("/location", locatiopnRouites);

// Shipment routes
router.use("/shipments", shipmentRoutes); // <-- mount

// paypalWebhook routes
// router.use("/api/stripe", stripeWebhookRoutes);

// address routes
router.use("/address", addressRoutes);
router.use("/", socketRoutes);

// driverKyc routes
router.use("/", driverKycRoutes);

router.use("/", adminRoutes); // <-- mount

export default router;
