import { DataTypes, Model, Optional, Sequelize } from "sequelize";
import User from "./user.model";

export interface KycAttributes {
  id?: number;
  driverId: number;
  licenseUrl: string;
  licenseNumber?: string;
  idCardUrl: string;
  idCardNumber?: string;
  rcUrl: string;
  rcNumber?: string;
  driverUrl: string;
  licenseValid: boolean;
  idCardValid: boolean;
  rcValid: boolean;
  verifiedStatus: "pending" | "verified" | "rejected";
  createdAt?: Date;
  updatedAt?: Date;
}

interface KycCreationAttributes
  extends Optional<KycAttributes, "id" | "verifiedStatus" | "createdAt" | "updatedAt"> {}

export class Kyc
  extends Model<KycAttributes, KycCreationAttributes>
  implements KycAttributes
{
  public id!: number;
  public driverId!: number;
  public licenseUrl!: string;
  public licenseNumber?: string;
  public idCardUrl!: string;
  public idCardNumber?: string;
  public rcUrl!: string;
  public rcNumber?: string;
  public driverUrl!: string;
  public licenseValid!: boolean;
  public idCardValid!: boolean;
  public rcValid!: boolean;
  public verifiedStatus!: "pending" | "verified" | "rejected";

  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize): typeof Kyc {
    Kyc.init(
      {
        id: {
          type: DataTypes.INTEGER,
          autoIncrement: true,
          primaryKey: true,
        },
        driverId: {
          type: DataTypes.INTEGER,
          allowNull: false,
          references: { model: User , key: "id" },
        },
        licenseUrl: DataTypes.STRING,
        licenseNumber: DataTypes.STRING,
        idCardUrl: DataTypes.STRING,
        idCardNumber: DataTypes.STRING,
        rcUrl: DataTypes.STRING,
        rcNumber: DataTypes.STRING,
        driverUrl: DataTypes.STRING,
        licenseValid: DataTypes.BOOLEAN,
        idCardValid: DataTypes.BOOLEAN,
        rcValid: DataTypes.BOOLEAN,
        verifiedStatus: {
          type: DataTypes.ENUM("pending", "awaiting_approval", "verified", "rejected"),
          defaultValue: "pending",
        },
      },
      {
        sequelize,
        tableName: "kyc",
        modelName: "Kyc",
        timestamps: true,
      }
    );
    return Kyc;
  }
}

export default Kyc;
