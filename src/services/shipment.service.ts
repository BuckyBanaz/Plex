import Stripe from "stripe";
import Shipment from "../models/shipment.model";
import { estimateFromGoogle } from "./estimation.service";
import haversine from "haversine-distance";
import User from "../models/user.model";
import UserLocation from "../models/userLocation.model";
import { sendFcmToToken } from "../utils/notifications";
import Vehicle from "../models/vehicle.model";
import { StripeWebhookEvent } from "../models/stripeWebhookEvent.model";
import DriverNotification from "../models/driverNotification.model";
import { sequelize } from "../db/database";
import admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";
import { Op } from "sequelize";
import fs from "fs";

const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

const stripe = new Stripe(config.STRIPE_SECRET_KEY!, {
  apiVersion: "2025-09-30.clover",
  typescript: true,
});

export const shipmentStatusFlow = [
  "created",
  "assigned",
  "picked_up",
  "in_transit",
  "delivered",
];

export class ShipmentService {
  /** Estimate shipment cost and distance */
  async estimate(params: {
    originLat: number;
    originLng: number;
    destinationLat: number;
    destinationLng: number;
    weight: number;
  }) {
    return await estimateFromGoogle(params);
  }

/** Create shipment with Stripe or COD payment */
async createWithPayment(data: {
  userId: number;
  vehicleType: string;
  images?: string[];
  collectTime: { type: "immediate" | "scheduled"; scheduledAt?: string };
  pickup: {
    name: string;
    phone: string;
    address: string;
    latitude: number;
    longitude: number;
  };
  dropoff: {
    name: string;
    phone: string;
    address: string;
    latitude: number;
    longitude: number;
  };
  weight?: string;
  notes?: string;
  paymentMethod: "stripe" | "cod";
  amount?: number;
}) {
  const {
    userId,
    vehicleType,
    images,
    collectTime,
    pickup,
    dropoff,
    weight,
    notes,
    paymentMethod,
    amount,
  } = data;

  // ======================================
  // 1️⃣ Estimate using Google or your logic
  // ======================================
  const rawEstimate = await estimateFromGoogle({
    originLat: pickup.latitude,
    originLng: pickup.longitude,
    destinationLat: dropoff.latitude,
    destinationLng: dropoff.longitude,
    weight: parseFloat(weight || "0"),
  });

  const safeEstimate = {
    distanceKm: Number(rawEstimate.distanceKm ?? 0),
    durationText: String(rawEstimate.durationText ?? ""),
    estimatedCostINR: Number(rawEstimate.estimatedCostINR ?? 0),
    estimatedCostUSD: Number(rawEstimate.estimatedCostUSD ?? 0),
    currency: String(rawEstimate.currency ?? "USD"),
  };

  // ======================================
  // 2️⃣ Create Shipment
  // ======================================
  const orderId = uuidv4();
  const invoiceNumber = `INV-${new Date().getFullYear()}${(
    "0" +
    (new Date().getMonth() + 1)
  ).slice(-2)}-${Math.floor(1000 + Math.random() * 9000)}`;

  const shipment = await Shipment.create({
    orderId,
    userId,
    vehicleType,
    images,
    collectTime,
    pickup,
    dropoff,
    weight,
    notes,
    estimate: safeEstimate,
    invoiceNumber,
    status: "created",
    paymentStatus: "pending",
    paymentMethod,
    estimatedCost: safeEstimate.estimatedCostINR,
    pricing: {
      currency: "INR",
      amount: safeEstimate.estimatedCostINR,
      distanceMeters: safeEstimate.distanceKm * 1000,
      priceBreakdown: {
        baseFare: Math.round(safeEstimate.estimatedCostINR * 0.4),
        distanceFare: Math.round(safeEstimate.estimatedCostINR * 0.55),
        tax: Number((safeEstimate.estimatedCostINR * 0.05).toFixed(2)),
      },
    },
  });

  // ======================================
  // 3️⃣ Notify Admin Dashboard Only
  // ======================================
  const io = (global as any).io;
  if (io) {
    io.emit("dashboard_newShipment", {
      shipmentId: shipment.id,
      status: "created",
      createdAt: shipment.createdAt,
      estimatedCost: shipment.estimatedCost,
    });
  }

  // ======================================
  // 4️⃣ STRIPE PAYMENT FLOW
  // ======================================
  if (paymentMethod === "stripe") {
    const paymentIntent = await stripe.paymentIntents.create({
      amount: Math.round((amount ?? safeEstimate.estimatedCostUSD) * 100),
      currency: "usd",
      metadata: {
        shipmentId: shipment.id.toString(),
        userId: userId.toString(),
      },
      automatic_payment_methods: {
        allow_redirects: "never",
        enabled: true,
      },
      description: `Shipment order ${orderId}`,
    });

    // Store PaymentIntent details
    await shipment.update({
      stripePaymentIntentId: paymentIntent.id,
      paymentStatus: "pending",
    });

    shipment.clientSecret = (paymentIntent.client_secret as string) ?? null;
    await shipment.save();

    // ⛔ IMPORTANT
    // 👉 NO driver notifications here for Stripe
    // 👉 Webhook will send driver notifications after payment success
    // DO NOT ADD ANY NEW_SHIPMENT EMITS HERE

    return {
      success: true,
      message: "Shipment created with Stripe payment",
      shipment,
      clientSecret: shipment.clientSecret,
      estimate: safeEstimate,
    };
  }

  // ======================================
  // 5️⃣ COD PAYMENT FLOW
  // ======================================
  // COD → notify nearby drivers immediately (only within 40km)
  const freshShipment = await Shipment.findByPk(shipment.id);
  await this.attemptNotifyShipment(shipment.id, 40);

  return {
    success: true,
    message: "Shipment created with Cash on Delivery",
    shipment,
    estimate: safeEstimate,
  };
}


  /** Confirm Stripe payment manually (fallback) */
  async confirmPaymentAndMark(shipmentId: number, paymentIntentId: string) {
    const paymentIntent = await stripe.paymentIntents.retrieve(paymentIntentId);
    console.log("paymentIntent ========> ", paymentIntent);

    if (paymentIntent.status !== "succeeded")
      throw new Error("Payment not completed");

    const shipment = await Shipment.findByPk(shipmentId);
    console.log("shipment ======> ", shipment);

    if (!shipment) throw new Error("Shipment not found");

    shipment.paymentStatus = "paid";
    shipment.status = "assigned";
    await shipment.save();

    try {
      const freshShipment = await Shipment.findByPk(shipment.id);
      if (freshShipment) {
        await this.notifyNearbyDrivers(freshShipment, { radiusKm: 40 });
      }
    } catch (err: any) {
      console.error("❌ notify error in confirmPaymentAndMark:", err.message);
    }

    const io = (global as any).io;
    if (io) io.emit("shipment_status", { shipmentId, status: shipment.status });

    return { success: true, shipment };
  }

  /** Auto Stripe Webhook handler */
  async handleStripeWebhook(req: any) {
    const sig = req.headers["stripe-signature"];
    console.log("sig ==========> ", sig);

    const webhookSecret =
      process.env.STRIPE_WEBHOOK_SECRET || config.STRIPE_WEBHOOK_SECRET;

      console.log("websocket ===========> ", webhookSecret)

    if (!webhookSecret) {
      console.error("❌ STRIPE_WEBHOOK_SECRET is not set");
      throw new Error("Webhook secret not configured");
    }

    let event: Stripe.Event;

    console.log("cnjidcjjsidjcijsidji");
    

    try {
      console.log("knsdklsdksdkskd =====================lksmdlkasdlkmsdlkjmsdkjl")
      event = stripe.webhooks.constructEvent(req.body, sig!, webhookSecret);
      console.log("event ========> ", event);

      console.log(" Stripe event received:", event.type);
    } catch (err: any) {
      console.error(" Signature verification failed:", err.message);
      throw new Error(`Webhook Error: ${err.message}`);
    }

  // ⭐ 1. CHECK IF EVENT ALREADY PROCESSED
  const alreadyProcessed = await StripeWebhookEvent.findByPk(event.id);
  if (alreadyProcessed) {
    console.log("⚠ Event already processed → skip:", event.id);
    return { received: true };
  }

  // ⭐ 2. MARK THIS EVENT AS PROCESSED
  await StripeWebhookEvent.create({ id: event.id });
  console.log("✅ Event marked as processed:", event.id);

    switch (event.type) {
      // Handle successful payment
      case "payment_intent.succeeded": {
        const intent = event.data.object as Stripe.PaymentIntent;
        console.log("PaymentIntent succeeded:", intent.id);

        const shipmentId = intent.metadata?.shipmentId
          ? Number(intent.metadata.shipmentId)
          : null;
        const userId = intent.metadata?.userId
          ? Number(intent.metadata.userId)
          : null;

        try {
          let shipment = null;

          // 1️ Try find by shipmentId (most reliable)
          if (shipmentId) {
            shipment = await Shipment.findByPk(shipmentId);
          }

          // 2️ Fallback by PaymentIntent & userId (if still not found)
          if (!shipment && userId) {
            shipment = await Shipment.findOne({
              where: { stripePaymentIntentId: intent.id, userId },
            });
          }

          // 3️ Still not found?
          if (!shipment) {
            console.warn("⚠️ No shipment found for PaymentIntent:", intent.id);
            return { received: true };
          }

          // =================================================

          // after you found `shipment`
          if (shipment.paymentStatus === "paid" && shipment.driversNotified === true) {
            console.log(`⚠ Shipment ${shipment.id} already processed by webhook → skip`);
            return { received: true };
          }
          // ======================================================

          //  Update DB
          shipment.paymentStatus = "paid";
          shipment.status = "assigned"; // or 'completed' if preferred
          await shipment.save();

          console.log(` Shipment #${shipment.id} → paid + assigned`);

          // Notify nearby drivers now that payment is successful
          try {
            await this.attemptNotifyShipment(shipment.id, 40);
          } catch (err: any) {
            console.error(
              "❌ Error notifying drivers after payment:",
              err.message
            );
          }

          // =================================================
          //  Notify USER that payment succeeded
          // =================================================
          try {
            const io = (global as any).io;
            if (io && shipment.userId) {
              io.to(`user_${shipment.userId}`).emit("paymentSuccess", {
                shipmentId: shipment.id,
                status: "paid",
                message: "Your payment was successful.",
              });
            }
          } catch (err: any) {
            console.error("❌ Error notifying user payment:", err.message);
          }

          //  Emit socket event (optional)
          const io = (global as any).io;
          if (io) {
            io.emit("shipment_status", {
              shipmentId: shipment.id,
              status: shipment.status,
            });
          }
        } catch (error: any) {
          console.error(" Error updating shipment (succeeded):", error.message);
        }

        break;
      }

      // Handle failed payment
      case "payment_intent.payment_failed": {
        const intent = event.data.object as Stripe.PaymentIntent;
        const shipmentId = intent.metadata?.shipmentId
          ? Number(intent.metadata.shipmentId)
          : null;

        if (shipmentId) {
          const shipment = await Shipment.findByPk(shipmentId);
          if (shipment) {
            shipment.paymentStatus = "failed";
            await shipment.save();
            console.log(` Shipment #${shipment.id} marked as failed`);
          }
        }
        break;
      }

      default:
        console.log(` Unhandled event type: ${event.type}`);
    }

    return { received: true };
  }

  /** Atomic driver accept — stores vehicleId + driverDetails in DB */
  async acceptShipmentAtomic(shipmentId: number, driverId: number) {
    const t = await sequelize.transaction();

    try {
      // Check shipment availability
      const shipment = await Shipment.findOne({
        where: {
          id: shipmentId,
          status: { [Op.in]: ["created", "assigned", "pending"] }, // only available shipments
        },
        transaction: t,
        lock: t.LOCK.UPDATE, // lock row for atomic update
      });

      if (!shipment) {
        await t.rollback();
        return {
          assigned: false,
          reason: "Shipment already taken or not found",
        };
      }

      // Ensure driver has a vehicle
      const vehicle = await Vehicle.findOne({
        where: { driverId },
        transaction: t,
      });
      if (!vehicle) {
        await t.rollback();
        return { assigned: false, reason: "Driver has no vehicle assigned" };
      }

      // Get driver details (optional: name, phone)
      const driver = await User.findByPk(driverId, { transaction: t });

      // Update shipment
      shipment.driverId = driverId;
      shipment.vehicleId = vehicle.id;
      shipment.driverDetails = {
        name: driver?.name || `Driver-${driverId}`,
        phone: driver?.mobile || "9999999999",
        vehicleType: vehicle?.type || null,
        licenseNumber: vehicle?.licenseNo || null,
      };
      shipment.status = "in_transit";
      shipment.driverAcceptedAt = new Date();

      await shipment.save({ transaction: t });
      await t.commit();

      // Notify sockets in real time
      const io = (global as any).io;
      if (io) {
        io.emit("shipment_status", {
          shipmentId,
          status: "in_transit",
          driverId,
        });
        io.to(`shipment_${shipmentId}`).emit("shipmentAccepted", shipment);
      }

      console.log(
        ` Shipment #${shipmentId} assigned to driver ${driverId} (vehicle ${vehicle.id})`
      );

      return { assigned: true, shipment };
    } catch (err: any) {
      await t.rollback();
      console.error(" acceptShipmentAtomic error:", err.message);
      throw err;
    }
  }

  /** Update driver location */
  async updateLocation(shipmentId: number, loc: { lat: number; lng: number }) {
    const shipment = await Shipment.findByPk(shipmentId);
    if (!shipment) throw new Error("Shipment not found");

    shipment.liveLocation = { ...loc, timestamp: new Date().toISOString() };
    await shipment.save();

    const io = (global as any).io;
    if (io) io.emit("driver_location", { shipmentId, location: loc });

    // Check proximity to dropoff — if within 0.5 km notify the driver app to enable delivered button
    try {
      const dropoff = shipment.dropoff;
      if (dropoff && dropoff.latitude && dropoff.longitude) {
        const dropCoords = {
          lat: Number(dropoff.latitude),
          lng: Number(dropoff.longitude),
        };
        const distanceKm =
          haversine(dropCoords, { lat: loc.lat, lng: loc.lng }) / 1000;

        // threshold 0.5 km
        if (distanceKm <= 0.5) {
          // emit socket to driver room enabling delivered button
          if (io && shipment.driverId) {
            io.to(`driver_${shipment.driverId}`).emit("enableDeliver", {
              shipmentId,
              message: "You are close to dropoff. You can mark as delivered.",
            });
          }

          // also send an FCM to driver if token exists
          try {
            const driver = await User.findByPk(shipment.driverId as number);
            if (driver && driver.fcmToken) {
              await sendFcmToToken(driver.fcmToken, {
                token: driver.fcmToken,
                notification: {
                  title: "You are near dropoff",
                  body: "Tap to mark as delivered.",
                },
                data: {
                  type: "ENABLE_DELIVER",
                  shipmentId: String(shipmentId),
                },
              } as any);
            }
          } catch (err: any) {
            console.error(" Error notifying driver proximity:", err.message);
          }
        }
      }
    } catch (err: any) {
      console.error(" Proximity check error:", err.message);
    }

    return { success: true, liveLocation: shipment.liveLocation };
  }

  async getShipmentById(id: number) {
    const shipment = await Shipment.findByPk(id);
    if (!shipment) throw new Error("Shipment not found");
    return shipment;
  }

  async getAllShipments() {
    return await Shipment.findAll({ order: [["createdAt", "DESC"]] });
  }

  async getLocation(shipmentId: number) {
    const shipment = await Shipment.findByPk(shipmentId);
    if (!shipment) throw new Error("Shipment not found");

    if (!shipment.liveLocation)
      return { message: "No live location available yet" };

    return {
      shipmentId,
      liveLocation: shipment.liveLocation,
      lastUpdated: shipment.liveLocation.timestamp || new Date().toISOString(),
    };
  }

  /** Get drivers within radius (km) who are online and have fcmToken */
  private async findNearbyDrivers(
    pickupLat: number,
    pickupLng: number,
    radiusKm = 40
  ) {
    const onlineDrivers = await User.findAll({
      where: { userType: "driver", isOnline: true },
      include: [{ model: UserLocation, as: "currentLocation" }],
    });

    const pickupCoords = { lat: pickupLat, lng: pickupLng };

    const nearby = onlineDrivers.filter((driver: any) => {
      if (!driver.currentLocation) return false;
      if (!driver.fcmToken) return false;
      const driverCoords = {
        lat: Number(driver.currentLocation.latitude),
        lng: Number(driver.currentLocation.longitude),
      };
      const distanceKm = haversine(pickupCoords, driverCoords) / 1000;
      return distanceKm <= radiusKm;
    });

    return nearby;
  }


/** Notify nearby drivers (Socket + FCM with duplicate-protection) */
private async notifyNearbyDrivers(
  shipment: any,
  opts?: { radiusKm?: number }
) {
  try {
    // 1) Atomic mark: set driversNotified = true only if currently false
    const [updatedCount] = await Shipment.update(
      { driversNotified: true },
      {
        where: {
          id: shipment.id,
          driversNotified: false,
        },
        limit: 1,
      }
    );

    // if no row updated, another process already notified -> skip
    if (updatedCount === 0) {
      console.log(`⛔ Shipment ${shipment.id} already notified (atomic check) → skipping`);
      return;
    }

    try {
      shipment.driversNotified = true;
      console.log(`✅ In-memory flag set for shipment ${shipment.id}`);
    } catch (e) {}

    // 2) Find nearby drivers
    const pickup = shipment.pickup || {};
    const pickupLat = Number(pickup.latitude);
    const pickupLng = Number(pickup.longitude);
    if (isNaN(pickupLat) || isNaN(pickupLng)) return;

    const radius = opts?.radiusKm ?? 40;
    const nearby = await this.findNearbyDrivers(pickupLat, pickupLng, radius);

    if (!nearby || nearby.length === 0) {
      console.log(`🚫 Shipment ${shipment.id}: no nearby drivers`);
      return;
    }

    // ⭐⭐⭐ ADD DEDUPE HERE ⭐⭐⭐
    const uniqueDriversMap = new Map();
    for (const d of nearby) uniqueDriversMap.set(d.id, d);
    const uniqueDrivers = Array.from(uniqueDriversMap.values());

    console.log(`🚗 Nearby drivers found: ${nearby.length}`);
    console.log(`🔍 Unique drivers after dedupe: ${uniqueDrivers.length}`);
    // ⭐⭐⭐ END DEDUPE ⭐⭐⭐

    const io = (global as any).io;
    const expiresAt = (Date.now() + 20 * 1000).toString();

    // Loop over unique drivers only
    for (const driver of uniqueDrivers) {
      try {
        const socketRoom = `driver_${driver.id}`;
        const token = driver.fcmToken;
        const driverSocketId = (driver as any).socketId;

    // ================================
    // ⭐ SAVE NOTIFICATION IN DATABASE
    // ================================
    await DriverNotification.create({
      driverId: driver.id,
      shipmentId: shipment.id,
      title: "New delivery near you",
      body: `Pickup: ${shipment.pickup?.address || "Nearby"} • ₹${shipment.estimatedCost}`,
      expiresAt: new Date(Date.now() + 60 * 60 * 1000), // auto delete after 1 hour
    });

    console.log(`💾 Notification stored for driver ${driver.id}`);

        const socketPayload = {
          shipment: {
            id: shipment.id,
            orderId: shipment.orderId,
            invoiceNumber: shipment.invoiceNumber,
            userId: shipment.userId,
            vehicleType: shipment.vehicleType,
            images: shipment.images ?? [],
            collectTime: shipment.collectTime ?? {},
            pickup: shipment.pickup ?? {},
            dropoff: shipment.dropoff ?? {},
            weight: shipment.weight ?? "",
            notes: shipment.notes ?? "",
            estimate: shipment.estimate ?? {},
            paymentStatus: shipment.paymentStatus ?? "pending",
            paymentMethod: shipment.paymentMethod ?? "cod",
            estimatedCost: shipment.estimatedCost ?? 0,
            pricing: shipment.pricing ?? {},
            createdAt: shipment.createdAt,
            updatedAt: shipment.updatedAt,
            stripePaymentIntentId: shipment.stripePaymentIntentId ?? null,
            clientSecret: shipment.clientSecret ?? null,
          },
          _meta: {
            source: "socket",
            expiresAt,
          },
        };

        // socket emit
        if (io) {
          io.to(socketRoom).emit("newShipment", socketPayload);
          console.log(`🚚 Sent newShipment to ${socketRoom}`);
        }

        // detect online driver
        let driverConnected = false;
        try {
          if (io && driverSocketId) {
            const socketsMap = io.sockets?.sockets;
            if (socketsMap?.get) {
              if (socketsMap.get(driverSocketId)) driverConnected = true;
            } else if (io.sockets?.connected?.[driverSocketId]) {
              driverConnected = true;
            }
          }
        } catch {}

        // FCM if offline
        if (!driverConnected && token) {
          const message: admin.messaging.Message = {
            token,
            notification: {
              title: "New delivery near you",
              body: `Pickup: ${shipment.pickup?.address || "Nearby"} • ₹${shipment.estimatedCost}`,
            },
            data: {
              type: "NEW_ORDER",
              shipmentId: String(shipment.id),
              invoice: String(shipment.invoiceNumber ?? ""),
              pickup: JSON.stringify(shipment.pickup ?? {}),
              dropoff: JSON.stringify(shipment.dropoff ?? {}),
              fare: String(shipment.estimatedCost ?? ""),
              expiresAt,
              source: "fcm",
            },
            android: { priority: "high", notification: { channelId: "orders" } },
            apns: {
              headers: { "apns-priority": "10" },
              payload: { aps: { sound: "default" } },
            },
          };

          await sendFcmToToken(token, message).catch((err) => {
            console.error("❌ FCM error:", err.message);
          });
          console.log(`📨 FCM sent to driver ${driver.id}`);
        } else {
          console.log(`⚡ Driver ${driver.id} online → skipped FCM`);
        }

      } catch (err: any) {
        console.error("❌ notifyNearbyDrivers driver error:", err?.message);
      }
    }

  } catch (err: any) {
    console.error("❌ notifyNearbyDrivers main error:", err?.message);
  }
}



  /** Notify user about delivery */
  private async notifyUserDelivery(shipment: any) {
    try {
      if (!shipment.userId) return;
      const user = await User.findByPk(shipment.userId);
      if (!user || !user.fcmToken) return;

      const message: admin.messaging.Message = {
        token: user.fcmToken,
        notification: {
          title: "Order delivered",
          body: `Your order ${shipment.invoiceNumber} has been delivered. Thank you!`,
        },
        data: {
          type: "DELIVERED",
          shipmentId: String(shipment.id),
          invoiceNumber: String(shipment.invoiceNumber || ""),
        },
      };

      await sendFcmToToken(user.fcmToken, message);
    } catch (err: any) {
      console.error("❌ notifyUserDelivery error:", err.message);
    }
  }

  async markAsDelivered(shipmentId: number, driverId?: number) {
    const shipment = await Shipment.findByPk(shipmentId);
    if (!shipment) throw new Error("Shipment not found");

    // optional: check driverId matches
    if (driverId && shipment.driverId && shipment.driverId !== driverId) {
      throw new Error("Driver not assigned to this shipment");
    }

    shipment.status = "delivered";
    shipment.paymentStatus = shipment.paymentStatus || "paid"; // ensure payment status
    shipment.deliveredAt = new Date();
    await shipment.save();

    // socket notify
    const io = (global as any).io;
    if (io) io.emit("shipment_status", { shipmentId, status: shipment.status });

    // notify user (FCM) and possibly email/invoice logic
    try {
      await this.notifyUserDelivery(shipment);
    } catch (err: any) {
      console.error(" notifyUserDelivery error:", err.message);
    }

    return { success: true, shipment };
  }


  /** Confirm Stripe PaymentIntent directly (manual trigger) */
async confirmStripePayment(paymentIntentId: string, payment_method: string, return_url?: string) {
  try {
    const paymentIntent = await stripe.paymentIntents.confirm(paymentIntentId, {
      payment_method,
      return_url,
    });

    console.log("✅ Stripe PaymentIntent confirmed:", paymentIntent.id, paymentIntent.status);

    if (paymentIntent.status === "succeeded" && paymentIntent.metadata?.shipmentId) {
      const shipmentId = Number(paymentIntent.metadata.shipmentId);
      const shipment = await Shipment.findByPk(shipmentId);

      if (!shipment) {
        console.log("❌ Shipment not found");
        return paymentIntent;
      }

         // VERY IMPORTANT — RE-FETCH FOR CORRECT STATE
      const freshShipment = await Shipment.findByPk(shipment.id);

      if (freshShipment) {
        await this.notifyNearbyDrivers(freshShipment, { radiusKm: 40 });
      } else {
        console.log("❌ Fresh shipment not found after save");
      }
    }

    // ===================================================================================

    return paymentIntent;
  } catch (err: any) {
    console.error("❌ confirmStripePayment error:", err.message);
    throw new Error(err.message);
  }
}

async getDriverNewShipments(driverId: number) {
  return await Shipment.findAll({
    where: {
      driversNotified: true,      // sent to drivers
      driverId: null,             // not yet accepted
      status: "assigned"          // assigned after payment success
    },
    order: [["createdAt", "DESC"]],
  });
}

/** Universal Shipment Notification Handler (COD + Stripe) */
async attemptNotifyShipment(shipmentId: number, radiusKm: number = 40) {
  const shipment = await Shipment.findByPk(shipmentId);
  if (!shipment) {
    console.log("⚠ attemptNotifyShipment: Shipment not found:", shipmentId);
    return;
  }

  // Only notify if payment is completed OR it's COD
  const canNotify =
    shipment.paymentMethod === "cod" ||
    shipment.paymentStatus === "paid";

  if (!canNotify) {
    console.log(`⏳ Shipment ${shipment.id} not ready for notifying drivers`);
    return;
  }

  // Use your existing system (atomic + dedupe)
  await this.notifyNearbyDrivers(shipment, { radiusKm });
}

}
