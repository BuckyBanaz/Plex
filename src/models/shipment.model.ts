import { Model, DataTypes, Optional, Sequelize } from "sequelize";
import User from "./user.model";
import Vehicle from "./vehicle.model";

interface ShipmentAttributes {
  id: number;
  orderId: string;
  reference?: string | null;
  invoiceNumber?: string | null;
  status:
    | "created"
    | "assigned"
    | "picked_up"
    | "in_transit"
    | "delivered"
    | "cancelled"
    | "failed";

  userId: number;
  vehicleType: string | null;
  driverId?: number | null; 
  vehicleId?: number | null;
  images?: string[] | null;
  collectTime: {
    type: "immediate" | "scheduled";
    scheduledAt?: string | null;
  };
  weight?: string | null;
  notes?: string | null;

  pickup : {
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

  driverDetails?: {
    name?: string;
    phone?: string;
    licenseNumber?: string | null;
    vehicleType?: string | null;
  } | null;

  schedule?: {
    scheduledPickupTime?: string;
    scheduledDeliveryTime?: string | null;
  };

  timing?: {
    assignedAt?: string | null;
    pickedAt?: string | null;
    deliveredAt?: string | null;
    cancelledAt?: string | null;
  };

  vehicleDetails?: {
    vehicleModel?: string;
    vehicleNumber?: string;
    vehicleOdometerStart?: number | null;
    vehicleOdometerEnd?: number | null;
  };

  pricing?: {
    currency?: string;
    amount?: number;
    distanceMeters?: number;
    priceBreakdown?: Record<string, any>;
  };

  estimate?: {
    distanceKm: number;
    durationText: string;
    estimatedCostINR: number;
    estimatedCostUSD: number;
    currency: string;
  };

  payment?: {
    method?: string;
    paid?: boolean;
    transactionId?: string | null;
  };

  tracking?: {
    status?: string;
    location?: { lat: number; lng: number };
    time?: string;
    note?: string;
  }[];

  liveLocation?: {
    lat?: number;
    lng?: number;
    timestamp?: string;
  } | null;

  tags?: string[] | null;

  estimatedCost?: number | null;
  stripePaymentIntentId?: string | null;
  paymentMethod: "stripe" | "cod";
  paymentStatus: "pending" | "paid" | "failed";
  clientSecret?: string | null;
  deliveredAt?: Date | null;
  driversNotified?: boolean;
  driverAcceptedAt?: Date | null;

  createdAt?: Date;
  updatedAt?: Date;
}

interface ShipmentCreationAttributes
  extends Optional<
    ShipmentAttributes,
    | "id"
    | "reference"
    | "images"
    | "weight"
    | "notes"
    | "driverId"
    | "vehicleId"
    | "driverDetails"
    | "schedule"
    | "timing"
    | "vehicleDetails"
    | "pricing"
    | "payment"
    | "tracking"
    | "liveLocation"
    | "tags"
    | "estimatedCost"
    | "stripePaymentIntentId"
    | "clientSecret"
    | "estimate"
    | "invoiceNumber"
    | "deliveredAt"
    | "driversNotified"
    | "driverAcceptedAt"
  > {}

export default class Shipment
  extends Model<ShipmentAttributes, ShipmentCreationAttributes>
  implements ShipmentAttributes
{
  public id!: number;
  public orderId!: string;
  public reference?: string | null;
  public invoiceNumber?: string | null;
  public status!: ShipmentAttributes["status"];
  public userId!: number;
  public vehicleType!: string | null;
  public driverId?: number | null;
  public vehicleId?: number | null;
  public images?: string[] | null;
  public collectTime!: ShipmentAttributes["collectTime"];
  public weight?: string | null;
  public notes?: string | null;
  public pickup!: ShipmentAttributes["pickup"];
  public dropoff!: ShipmentAttributes["dropoff"];
  public driverDetails?: ShipmentAttributes["driverDetails"];
  public schedule?: ShipmentAttributes["schedule"];
  public timing?: ShipmentAttributes["timing"];
  public vehicleDetails?: ShipmentAttributes["vehicleDetails"];
  public pricing?: ShipmentAttributes["pricing"];
  public estimate?: ShipmentAttributes["estimate"];
  public payment?: ShipmentAttributes["payment"];
  public tracking?: ShipmentAttributes["tracking"];
  public liveLocation?: ShipmentAttributes["liveLocation"];
  public tags?: string[] | null;
  public estimatedCost?: number | null;
  public stripePaymentIntentId?: string | null;
  public paymentMethod!: "stripe" | "cod";
  public paymentStatus!: "pending" | "paid" | "failed";
  public clientSecret?: string | null;
  public deliveredAt?: Date | null;
  public driversNotified?: boolean | undefined;
  public driverAcceptedAt?: Date | null;
  declare readonly createdAt?: Date | undefined;
  declare readonly updatedAt?: Date | undefined;

  static initModel(sequelize: Sequelize) {
    Shipment.init(
      {
        id: { type: DataTypes.INTEGER, autoIncrement: true, primaryKey: true },
        orderId: { type: DataTypes.STRING, allowNull: false, unique: true },
        reference: { type: DataTypes.STRING, allowNull: true },
        invoiceNumber: { type: DataTypes.STRING, allowNull: true, unique: true },
        status: {
          type: DataTypes.ENUM(
            "created",
            "assigned",
            "picked_up",
            "in_transit",
            "delivered",
            "cancelled",
            "failed"
          ),
          defaultValue: "created",
        },
        userId: { type: DataTypes.INTEGER, allowNull: false },
        vehicleType: { type: DataTypes.STRING, allowNull: true },
        driverId: { type: DataTypes.INTEGER, allowNull: true },
        vehicleId: { type: DataTypes.INTEGER, allowNull: true },
        images: { type: DataTypes.ARRAY(DataTypes.STRING), allowNull: true },
        collectTime: { type: DataTypes.JSONB, allowNull: true },
        weight: { type: DataTypes.STRING, allowNull: true },
        notes: { type: DataTypes.TEXT, allowNull: true },
        pickup: { type: DataTypes.JSONB, allowNull: true },
        dropoff: { type: DataTypes.JSONB, allowNull: true },
        driverDetails: { type: DataTypes.JSONB, allowNull: true },
        schedule: { type: DataTypes.JSONB, allowNull: true },
        timing: { type: DataTypes.JSONB, allowNull: true },
        vehicleDetails: { type: DataTypes.JSONB, allowNull: true },
        pricing: { type: DataTypes.JSONB, allowNull: true },
        estimate: { type: DataTypes.JSONB, allowNull: true },
        payment: { type: DataTypes.JSONB, allowNull: true },
        tracking: { type: DataTypes.JSONB, allowNull: true },
        liveLocation: { type: DataTypes.JSONB, allowNull: true },
        tags: { type: DataTypes.ARRAY(DataTypes.STRING), allowNull: true },
        estimatedCost: { type: DataTypes.FLOAT, allowNull: true },
        stripePaymentIntentId: { type: DataTypes.STRING, allowNull: true },
        paymentMethod: {
          type: DataTypes.ENUM("stripe", "cod"),
          defaultValue: "stripe",
        },
        paymentStatus: {
          type: DataTypes.ENUM("pending", "paid", "failed"),
          defaultValue: "pending",
          allowNull: false,
        },
        clientSecret: { type: DataTypes.STRING, allowNull: true },
        deliveredAt: { type: DataTypes.DATE, allowNull: true },
        driversNotified: {
        type: DataTypes.BOOLEAN,
        defaultValue: false,
        allowNull: false,
      },
      driverAcceptedAt: { type: DataTypes.DATE, allowNull: true },
      },
      {
        tableName: "shipments",
        sequelize,
        timestamps: true,
      }
    );
  }

  static associate() {
    Shipment.belongsTo(User, { foreignKey: "userId", as: "user" });
    Shipment.belongsTo(Vehicle, { foreignKey: "vehicleId", as: "vehicle" });
  }
}
