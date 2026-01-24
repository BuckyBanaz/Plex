import express, { Request, Response } from "express";
import { ShipmentService } from "../services/shipment.service";

const router = express.Router();
const shipmentService = new ShipmentService();

// Stripe needs raw body
router.post(
  "/webhook",
  express.raw({ type: "application/json" }),
  async (req: Request, res: Response) => {
    let responseSent = false;

    try {
      console.log("📬 Stripe webhook received...");

      // Respond instantly
      res.status(200).json({ received: true });
      responseSent = true;

      // Process webhook async
      shipmentService
        .handleStripeWebhook(req)
        .catch(err => console.error("❌ Async error:", err));
    } catch (err: any) {
      if (!responseSent) {
        res.status(400).send(`Webhook Error: ${err.message}`);
      }
    }
  }
);

export default router;
