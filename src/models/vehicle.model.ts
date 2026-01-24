import { Model, DataTypes, Optional, Sequelize } from "sequelize";
import User from "./user.model";

// 1️⃣ Define full Vehicle attributes
interface VehicleAttributes {
  id: number;
  type: string; // existing
  licenseNo: string;
  driverId: number;
  ownerName?: string;
  registeringAuthority?: string;
  vehicleType?: string;
  fuelType?: string;
  vehicleAge?: number;
  vehicleStatus?: "inactive" | "active";
  vehicleImageUrl?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

// 2️⃣ Define creation attributes (omit auto fields)
interface VehicleCreationAttributes
  extends Optional<
    VehicleAttributes,
    | "id"
    | "createdAt"
    | "updatedAt"
    | "ownerName"
    | "registeringAuthority"
    | "vehicleType"
    | "fuelType"
    | "vehicleAge"
    | "vehicleStatus"
    | "vehicleImageUrl"
  > {}

// 3️⃣ Define class model
export default class Vehicle
  extends Model<VehicleAttributes, VehicleCreationAttributes>
  implements VehicleAttributes
{
  public id!: number;
  public type!: string;
  public licenseNo!: string;
  public driverId!: number;

  public ownerName?: string;
  public registeringAuthority?: string;
  public vehicleType?: string;
  public fuelType?: string;
  public vehicleAge?: number;
  public vehicleStatus?: "inactive" | "active";
  public vehicleImageUrl?: string;

  // ✅ These are required so TS recognizes them
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  // Optional association
  public driver?: User;

  // 4️⃣ Initialize model
  static initModel(sequelize: Sequelize): typeof Vehicle {
    Vehicle.init(
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true,
        },
        type: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        licenseNo: {
          type: DataTypes.STRING,
          allowNull: false,
          unique: true,
        },
        driverId: {
          type: DataTypes.INTEGER,
          allowNull: false,
          references: { model: User, key: "id" },
        },
        ownerName: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        registeringAuthority: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        vehicleType: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        fuelType: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        vehicleAge: {
          type: DataTypes.INTEGER,
          allowNull: true,
        },
        vehicleStatus: {
          type: DataTypes.ENUM("inactive", "active"),
          defaultValue: "inactive",
        },
        vehicleImageUrl: {
          type: DataTypes.STRING,
          allowNull: true,
        },
      },
      {
        tableName: "vehicles",
        sequelize,
        timestamps: true,
        modelName: "Vehicle",
      }
    );

    // Define associations here
    Vehicle.belongsTo(User, { foreignKey: "driverId", as: "driver" });

    return Vehicle;
  }
}
