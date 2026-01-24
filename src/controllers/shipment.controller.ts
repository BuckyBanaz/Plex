import { Request, Response } from "express";
import { ShipmentService } from "../services/shipment.service";
import Shipment from "../models/shipment.model"
import { Vehicle } from "../models";

const shipmentService = new ShipmentService();

export class ShipmentController {
  //  1. Estimate shipment cost
  async estimate(req: Request, res: Response) {
    try {
      const { originLat, originLng, destinationLat, destinationLng, weight } = req.body;
      if ([originLat, originLng, destinationLat, destinationLng, weight].some(v => v === undefined)) {
        return res.status(400).json({ success: false, message: "Missing parameters" });
      }

      const result = await shipmentService.estimate({
        originLat: Number(originLat),
        originLng: Number(originLng),
        destinationLat: Number(destinationLat),
        destinationLng: Number(destinationLng),
        weight: Number(weight),
      });

      res.status(200).json({
        success: true,
        message: "Estimated cost and distance calculated successfully",
        data: result,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  2. Create new shipment (Stripe or COD)
  async createShipment(req: Request, res: Response) {
    try {
      const {
        userId,
        vehicleType,
        collectTime,
        pickup,
        dropoff,
        weight,
        notes,
        paymentMethod,
        amount,
      } = req.body;

      //  handle uploaded file URLs from S3
      const images = (req.files as Express.MulterS3.File[] | undefined)?.map(f => f.location) || [];

      if (
        !userId ||
        !vehicleType ||
        !pickup ||
        !dropoff ||
        !collectTime ||
        !paymentMethod
      ) {
        return res.status(400).json({
          success: false,
          message: "Missing required parameters",
        });
      }

      const result = await shipmentService.createWithPayment({
        userId: Number(userId),
        vehicleType: String(vehicleType),
        images: images ?? [],
        collectTime,
        pickup,
        dropoff,
        weight: weight ? String(weight) : undefined,
        notes: notes ?? "",
        paymentMethod: paymentMethod as "stripe" | "cod",
        amount: amount ? Number(amount) : undefined,
      });

      res.status(201).json({
        success: true,
        message: result.message,
        shipment: result.shipment,
        clientSecret: result.clientSecret ?? null,
        estimate: result.estimate,
      });
    } catch (err: any) {
      console.error("❌ Create shipment error:", err);
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  3. Confirm Stripe payment
  async confirmPayment(req: Request, res: Response) {
    try {
      const { shipmentId, paymentIntentId } = req.body;
      if (!shipmentId || !paymentIntentId) {
        return res.status(400).json({ success: false, message: "Missing parameters" });
      }

      const shipment = await shipmentService.confirmPaymentAndMark(
        Number(shipmentId),
        paymentIntentId
      );

      res.status(200).json({
        success: true,
        message: "Payment confirmed successfully",
        data: shipment,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  4. Stripe webhook
  async stripeWebhook(req: Request, res: Response) {
    try {
      await shipmentService.handleStripeWebhook(req);
      res.status(200).send("Webhook processed successfully");
    } catch (err: any) {
      res.status(400).json({ success: false, message: err.message });
    }
  }

//  5. Driver accepts shipment
async acceptShipment(req: Request, res: Response) {
  try {
    if (!req.user || req.user.id === undefined)
      return res.status(401).json({ success: false, message: "Unauthorized" });

    const shipmentId = Number(req.params.id);
    const driverId = Number(req.user.id);

    const result = await shipmentService.acceptShipmentAtomic(shipmentId, driverId);

    if (!result.assigned) {
      return res.status(409).json({ success: false, message: result.reason });
    }

    const updated = result.shipment!;
    const io = req.app.get("io");

     // Notify shipment room
    if (io)
      io.to(`shipment_${shipmentId}`).emit("shipmentAccepted", updated);

    // ⭐ Notify user room (user receives driver accepted notification)
    if (io && updated.userId) {
      io.to(`user_${updated.userId}`).emit("driverAccepted", {
        shipmentId,
        driver: updated.driverDetails
      });
    }

    return res.status(200).json({ success: true, shipment: updated });

  } catch (err: any) {
    console.error("❌ Accept shipment error:", err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

  //  6. Update driver location
  async updateLocation(req: Request, res: Response) {
    try {
      if (!req.user || req.user.id === undefined)
        return res.status(401).json({ success: false, message: "Unauthorized" });

      const shipmentId = Number(req.params.id);
      const { lat, lng } = req.body;
      if (lat === undefined || lng === undefined)
        return res.status(400).json({ success: false, message: "Missing lat/lng" });

      const updatedLoc = await shipmentService.updateLocation(shipmentId, {
        lat: Number(lat),
        lng: Number(lng),
      });

      const io = req.app.get("io");
      if (io) io.to(`shipment_${shipmentId}`).emit("locationUpdate", updatedLoc);

      res.status(200).json({
        success: true,
        message: "Location updated successfully",
        data: updatedLoc,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  7. Get current location
  async getLocation(req: Request, res: Response) {
    try {
      const { id } = req.params;
      const result = await shipmentService.getLocation(Number(id));
      res.status(200).json({
        success: true,
        message: "Current location retrieved successfully",
        data: result,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  8. Get all shipments
  async getAllShipments(req: Request, res: Response) {
    try {
      const list = await shipmentService.getAllShipments();
      res.status(200).json({
        success: true,
        message: "All shipments retrieved successfully",
        data: list,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  9. Get shipment by ID
  async getShipmentById(req: Request, res: Response) {
    try {
      const shipment = await shipmentService.getShipmentById(Number(req.params.id));
      if (!shipment)
        return res.status(404).json({ success: false, message: "Shipment not found" });

      res.status(200).json({
        success: true,
        message: "Shipment details retrieved successfully",
        data: shipment,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  10. Update shipment (Admin)
  async updateShipment(req: Request, res: Response) {
    try {
      const shipmentId = Number(req.params.id);
      const updateData = req.body;

      const shipment = await shipmentService.getShipmentById(shipmentId);
      if (!shipment)
        return res.status(404).json({ success: false, message: "Shipment not found" });

      await shipment.update(updateData);
      res.status(200).json({
        success: true,
        message: "Shipment updated successfully",
        data: shipment,
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  //  11. Delete shipment
  async deleteShipment(req: Request, res: Response) {
    try {
      const shipmentId = Number(req.params.id);
      const shipment = await shipmentService.getShipmentById(shipmentId);
      if (!shipment)
        return res.status(404).json({ success: false, message: "Shipment not found" });

      await shipment.destroy();
      res.status(200).json({
        success: true,
        message: "Shipment deleted successfully",
      });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }

  // 12. Driver marks as delivered
  async deliverShipment(req: Request, res: Response) {
    try {
      if (!req.user || req.user.id === undefined)
        return res.status(401).json({ success: false, message: "Unauthorized" });

      const shipmentId = Number(req.params.id);
      const driverId = Number(req.user.id);

      // ensure driver is assigned to this shipment (optional)
      const shipment = await shipmentService.getShipmentById(shipmentId);
      if (!shipment) return res.status(404).json({ success: false, message: "Shipment not found" });

      if (shipment.driverId && shipment.driverId !== driverId) {
        return res.status(403).json({ success: false, message: "You are not assigned to this shipment" });
      }

      const result = await shipmentService.markAsDelivered(shipmentId, driverId);

      res.status(200).json({ success: true, message: "Shipment marked delivered", data: result });
    } catch (err: any) {
      res.status(500).json({ success: false, message: err.message });
    }
  }


  // 13. Confirm Stripe payment directly (backend confirmation)
async confirmStripePayment(req: Request, res: Response) {
  try {
    const { paymentIntentId, payment_method = "pm_card_visa", return_url } = req.body;

    if (!paymentIntentId) {
      return res.status(400).json({ success: false, message: "paymentIntentId is required" });
    }

    const result = await shipmentService.confirmStripePayment(
      paymentIntentId,
      payment_method,
      return_url
    );

    res.status(200).json({
      success: true,
      message: "PaymentIntent confirmed successfully",
      data: result,
    });
  } catch (err: any) {
    console.error("❌ confirmStripePayment error:", err.message);
    res.status(400).json({ success: false, message: err.message });
  }
}

async getDriverNotifications(req: Request, res: Response) {
  try {
    const driverId = Number(req.user!.id);

    const shipments = await shipmentService.getDriverNewShipments(driverId);

    return res.status(200).json({
      success: true,
      message: "Driver notifications fetched",
      data: shipments
    });
  } catch (err: any) {
    return res.status(500).json({ success: false, message: err.message });
  }
}

async getDriverActiveShipments(req: Request, res: Response) {
  try {
    const driverId = Number(req.user!.id);

    const shipments = await Shipment.findAll({
      where: {
        driverId,
        status: ["assigned", "in_transit", "picked_up"]
      },
      order: [["updatedAt", "DESC"]],
    });

    return res.status(200).json({
      success: true,
      message: "Active driver shipments",
      data: shipments,
    });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
}

async getUserNotifications(req: Request, res: Response) {
  try {
    const userId = Number(req.user!.id);

    const shipments = await Shipment.findAll({
      where: { userId },
      order: [["updatedAt", "DESC"]],
    });

    const notifications = shipments.map((ship: any) => ({
      shipmentId: ship.id,
      status: ship.status,
      paymentStatus: ship.paymentStatus,
      driverId: ship.driverId,
      updatedAt: ship.updatedAt,
      orderId: ship.orderId,
      invoiceNumber: ship.invoiceNumber
    }));

    return res.status(200).json({
      success: true,
      message: "User notifications loaded",
      data: notifications
    });
  } catch (err: any) {
    res.status(500).json({ success: false, message: err.message });
  }
}


}


