import { Router, Request, Response } from "express";
import Shipment from "../models/shipment.model";
import User from "../models/user.model";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Socket
 *   description: Socket.IO connection details, online drivers, and shipment overview
 */

/**
 * @swagger
 * /socket-connection:
 *   get:
 *     summary: "🔌 Socket.IO Connection Information + Online Drivers + Shipments"
 *     description: |
 *       Returns Socket.IO configuration info, all created shipments, and a list of all online drivers.
 *     tags: [Socket]
 *     responses:
 *       200:
 *         description: "Socket connection information + online drivers + all shipments"
 */
router.get("/socket-connection", async (req: Request, res: Response) => {
  try {
    // ✅ Fetch all shipments (latest first)
    const shipments = await Shipment.findAll({
      order: [["createdAt", "DESC"]],
      limit: 50,
    });

    // ✅ Fetch all online drivers (without socketId)
    const onlineDrivers = await User.findAll({
      where: { userType: "driver", isOnline: true },
      attributes: [
        "id",
        "name",
        "email",
        "fcmToken",
        "isOnline",
        "createdAt",
        "updatedAt",
      ],
    });

    res.json({
      success: true,
      socket_url: "https://p2dev10.in",
      socket_path: "/socket.io/",
      transport: "websocket",
      auth: "Use JWT token as query parameter (?token=<JWT_TOKEN>)",
      totalShipments: shipments.length,
      totalOnlineDrivers: onlineDrivers.length,
      onlineDrivers,
      shipments,
      events: [
        { event: "newShipment", description: "Notifies drivers of new nearby shipments" },
        { event: "shipment_status", description: "Updates shipment status (assigned → delivered)" },
        { event: "locationUpdate", description: "Sends driver's live GPS updates" },
        { event: "enableDeliver", description: "Alerts driver when near drop-off" },
        { event: "order_confirmed", description: "Confirms when driver accepts shipment" },
        { event: "order_taken", description: "Informs driver if shipment already taken" },
      ],
    });
  } catch (err: any) {
    console.error("❌ Error fetching socket overview:", err.message);
    res.status(500).json({
      success: false,
      message: "Failed to fetch shipments or drivers info",
      error: err.message,
    });
  }
});

/**
 * @swagger
 * /socket-emit-all:
 *   get:
 *     summary: "Emit all existing shipments from database"
 *     description: "Fetches all shipments from DB and emits them via newShipment event to connected sockets"
 *     tags: [Socket]
 *     responses:
 *       200:
 *         description: "All DB shipments emitted successfully"
 */
router.get("/socket-emit-all", async (req: Request, res: Response) => {
  try {
    const io = (global as any).io;
    if (!io) {
      return res.status(500).json({ success: false, message: "Socket.IO not initialized" });
    }

    // ✅ Fetch real shipments from DB
    const shipments = await Shipment.findAll({
      order: [["createdAt", "DESC"]],
      limit: 50,
    });

    if (shipments.length === 0) {
      console.log("⚠️ No shipments found in database.");
      return res.json({ success: false, message: "No shipments found in DB" });
    }

    // ✅ Emit each shipment via Socket.IO
    for (const shipment of shipments) {
      const payload = {
        id: shipment.id,
        orderId: shipment.orderId,
        pickup: shipment.pickup,
        dropoff: shipment.dropoff,
        estimatedCost: shipment.estimatedCost,
        status: shipment.status,
        createdAt: shipment.createdAt,
      };

      io.emit("newShipment", payload);
      console.log(`🚀 Emitted existing shipment via Socket.IO: #${shipment.id}`);
    }

    res.json({
      success: true,
      count: shipments.length,
      message: `Emitted ${shipments.length} shipments successfully.`,
    });
  } catch (err: any) {
    console.error("❌ /socket-emit-all failed:", err.message);
    res.status(500).json({ success: false, message: err.message });
  }
});


export default router;
