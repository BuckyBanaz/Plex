import dotenv from "dotenv";
dotenv.config();

import { createServer } from "http";
import { Server } from "socket.io";
import app from "./app";
import { initDatabase } from "./src/db/database";
import logger from "./src/utils/logger";
import { initSMTP } from "./src/utils/sendEmail";
import { initFirebase } from "./src/utils/firebase";
import fs from "fs";
import path from "path";
import jwt from "jsonwebtoken";
import { createClient } from "redis";
import { createAdapter } from "@socket.io/redis-adapter";
import User from "./src/models/user.model";
import { testTextractConnection } from "./test-textract";
import { testAwsIdentity } from "./testAwsIdentity";
import "./src/utils/cron/deleteOldNotifications";


const configPath = path.join(__dirname, "src", "config", "config.json");
const config = fs.existsSync(configPath)
  ? JSON.parse(fs.readFileSync(configPath, "utf-8"))
  : {};

const PORT = process.env.PORT || config.PORT || 3000;
const JWT_SECRET = config.JWT_SECRET || "secret123";

// ==================================================
//  SERVER INITIALIZATION
// ==================================================
async function startServer() {
  try {
    // 1️ Init Database + Services
    await initDatabase();
    await initSMTP();
    initFirebase();

    // Run Textract connection test in background

    //     // 🚀 Test AWS identity
    // testAwsIdentity()
    //   .then(() => console.log("✅ AWS identity verified"))
    //   .catch((err) => console.error("❌ AWS identity check failed:", err));


    // // ✅ Run the Textract test automatically at startup
    // testTextractConnection()
    //   .then(() => console.log("✅ Textract test completed"))
    //   .catch((err) =>
    //     console.error("❌ Textract test failed:", err.message || err)
    //   );

    logger.info(" Database connected successfully");

    // 2️ HTTP + SOCKET.IO SETUP
    const httpServer = createServer(app);
    const io = new Server(httpServer, {
      cors: { origin: "*", methods: ["GET", "POST"] },
      path: "/socket.io/",
      transports: ["websocket"],
    });

    // 3️ Redis adapter (for scaling multiple instances)
    try {
      const pubClient = createClient({
        url: process.env.REDIS_URL || "redis://127.0.0.1:6379",
      });
      const subClient = pubClient.duplicate();
      await Promise.all([pubClient.connect(), subClient.connect()]);
      io.adapter(createAdapter(pubClient, subClient));
      logger.info(" Redis adapter connected for Socket.IO");
    } catch (err: any) {
      logger.warn(" Redis adapter not available:", err.message);
    }

    // Make io globally accessible
    (global as any).io = io;

    // ==================================================
    //  SOCKET AUTHENTICATION MIDDLEWARE
    // ==================================================
    io.use(async (socket, next) => {
      try {
        const token = socket.handshake.query?.token as string;
        if (!token) return next(new Error("Auth token missing"));
        const decoded: any = jwt.verify(token, JWT_SECRET);

        socket.data.driverId = decoded.id;
        logger.info(` Authenticated driver: ${decoded.id}`);
        next();
      } catch (err: any) {
        logger.error(" Socket auth failed:", err.message);
        next(new Error("Authentication failed"));
      }
    });

    // ==================================================
    //  SOCKET CONNECTION HANDLER
    // ==================================================
    io.on("connection", async (socket) => {
      const driverId = socket.data.driverId;
      logger.info(` Driver connected: ${driverId} | Socket ID: ${socket.id}`);

        // 🟢 USER ROOM JOINING HERE
        if (socket.handshake.query.userId) {
          const userId = socket.handshake.query.userId;
          socket.join(`user_${userId}`);
          console.log(`🟢 User joined room: user_${userId}`);
        }

      // Mark driver online and save socketId
      try {
        await (User as any).update(
          { socketId: socket.id, isOnline: true },
          { where: { id: driverId } }
        );
      } catch (err: any) {
        logger.error(" Error setting driver online:", err.message);
      }

      socket.join(`driver_${driverId}`);
      console.log(` Driver joined driver_${driverId}`);


      // =====================================================
      // SEND ASSIGNED / ACTIVE SHIPMENTS ON DRIVER CONNECT
      // =====================================================
      try {
        const Shipment = (await import("./src/models/shipment.model")).default;

        const assignedShipments = await Shipment.findAll({
          where: {
            driverId: driverId,
            status: ["assigned", "in_transit", "picked_up"], // active delivery statuses
          },
          order: [
            ["driverAcceptedAt", "DESC"],    // newest accepted shipment
            ["updatedAt", "DESC"]
          ]
        });

        socket.emit("assignedShipments", assignedShipments || []);
        console.log(
          `✔ Sent ${assignedShipments.length} assigned shipments to driver ${driverId}`
        );
      } catch (err: any) {
        console.error("❌ Error loading assigned shipments:", err.message);
      }

      // =====================================================
      //  Send all existing shipments when driver connects
      // =====================================================
      try {
        const Shipment = (await import("./src/models/shipment.model")).default;
        const shipments = await Shipment.findAll({
          order: [["createdAt", "DESC"]],
          limit: 20,
        });

        if (shipments.length > 0) {
          socket.emit("existingShipments", shipments);
          logger.info(
            ` Sent ${shipments.length} existing shipments to driver ${driverId}`
          );
        } else {
          socket.emit("existingShipments", []);
          logger.info(
            ` No existing shipments to send for driver ${driverId}`
          );
        }
      } catch (err: any) {
        logger.error(
          ` Failed to fetch existing shipments for driver ${driverId}:`,
          err.message
        );
      }

      // ================================================
      //  DRIVER EVENTS
      // ================================================

      // Driver accepts shipment
      socket.on("accept_order", async (data: { orderId: number }) => {
        try {
          const {
            ShipmentService,
          } = require("./src/services/shipment.service");
          const shipmentService = new ShipmentService();

          const result = await shipmentService.acceptShipment(
            data.orderId,
            driverId,
            0
          );

          socket.emit("order_confirmed", { shipment: result.shipment });
          io.emit("shipment_status", {
            shipmentId: data.orderId,
            status: "in_transit",
          });

          logger.info(
            ` Order ${data.orderId} accepted by driver ${driverId}`
          );
        } catch (err: any) {
          logger.error(" accept_order error:", err.message);
          socket.emit("error", { message: err.message });
        }
      });

      // Driver rejects order
      socket.on("reject_order", async (data: { orderId: number }) => {
        io.emit("shipment_status", {
          orderId: data.orderId,
          status: "rejected",
        });
        logger.info(` Driver ${driverId} rejected order ${data.orderId}`);
      });

      // Live location updates
      socket.on("locationUpdate", (data: { lat: number; lng: number }) => {
        io.to(`driver_${driverId}`).emit("locationUpdate", data);
        logger.info(` Driver ${driverId} location: ${JSON.stringify(data)}`);
      });

      // Manual join rooms
      socket.on("joinShipment", (shipmentId: number) => {
        socket.join(`shipment_${shipmentId}`);
        logger.info(` Joined shipment_${shipmentId}`);
      });

      socket.on("joinDriver", (id: number) => {
        socket.join(`driver_${id}`);
        logger.info(` Joined driver_${id}`);
      });

      //  Add your new event here
      socket.on("driver_ready", async (data) => {
        const driverId = data?.driverId || socket.data.driverId;
        socket.join(`driver_${driverId}`);
        logger.info(` driver_ready received → joined driver_${driverId}`);

        // optionally send confirmation
        socket.emit("driver_ready_ack", { joined: true, driverId });
      });

      // Handle disconnect
      socket.on("disconnect", async () => {
        logger.info(`🔌 Driver disconnected: ${driverId}`);
        try {
          await (User as any).update(
            { isOnline: false, socketId: null },
            { where: { id: driverId } }
          );
        } catch (err: any) {
          logger.error(" Error marking driver offline:", err.message);
        }
      });
    });

    // ==================================================
    //  EXPRESS TEST ENDPOINTS
    // ==================================================
    app.get("/", (req, res) =>
      res.send(" Socket.IO + Express Server Running")
    );
    app.get("/socket-test", (req, res) => {
      if ((global as any).io)
        return res.json({
          success: true,
          message: " Socket.IO server is running",
          path: "/socket.io/",
        });
      return res
        .status(500)
        .json({ success: false, message: " Socket.IO not initialized" });
    });

    // ==================================================
    //  START SERVER
    // ==================================================
    httpServer.listen(PORT, "0.0.0.0", () => {
      logger.info(` Server running on port ${PORT}`);
    });
  } catch (err: any) {
    logger.error(` Server start failed: ${err.message}`, err);
    process.exit(1);
  }
}

startServer();
