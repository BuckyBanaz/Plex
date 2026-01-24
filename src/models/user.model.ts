import { Model, DataTypes, Optional, Sequelize } from "sequelize";
import type CorporateDetail from "./corporate.model";
import UserLocation from "./userLocation.model";
import UserLocationHistory from "./userLocationHistory.model";
import UserAddress from "./userAddress.model";

export type UserType = "individual" | "corporate" | "guest" | "driver";

interface UserAttributes {
  id: number;
  name: string;
  email?: string | null;
  password?: string | null;
  userType: UserType;
  mobile?: string | null;
  isMobileVerified: boolean;
  isEmailVerified: boolean;
  deviceId: string;
  fcmToken?: string | null;
  isOnline: boolean;
  
  // Add aliases for associations
  currentLocation?: UserLocation; // for hasOne current location
  locationHistory?: UserLocationHistory[]; // for hasMany location history
  corporateDetail?: CorporateDetail;

  addresses?: UserAddress[];

  createdAt?: Date;
  updatedAt?: Date;
}

interface UserCreationAttributes
  extends Optional<
    UserAttributes,
    "id" | "email" | "password" | "mobile" | "isMobileVerified" | "isEmailVerified" | "isOnline"
  > {}

export default class User
  extends Model<UserAttributes, UserCreationAttributes>
  implements UserAttributes
{
  public id!: number;
  public name!: string;
  public email!: string | null;
  public password!: string | null;
  public userType!: UserType;
  public mobile?: string | null;
  public isMobileVerified!: boolean;
  public isEmailVerified!: boolean;
  public deviceId!: string;
  public fcmToken?: string | null;
  public isOnline!: boolean;

  // Association properties
  public currentLocation?: UserLocation;
  public locationHistory?: UserLocationHistory[];
  public corporateDetail?: CorporateDetail;

  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize) {
    User.init(
      {
        id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
        name: { type: DataTypes.STRING, allowNull: false },
        email: { type: DataTypes.STRING, allowNull: true },
        password: { type: DataTypes.STRING, allowNull: true },
        userType: {
          type: DataTypes.ENUM("individual", "corporate", "guest", "driver"),
          allowNull: false,
          defaultValue: "individual",
        },
        mobile: { type: DataTypes.STRING, allowNull: true },
        isMobileVerified: { type: DataTypes.BOOLEAN, defaultValue: false },
        isEmailVerified: { type: DataTypes.BOOLEAN, defaultValue: false },
        deviceId: { type: DataTypes.STRING, allowNull: true },
        fcmToken: { type: DataTypes.STRING, allowNull: true},
        isOnline: { type: DataTypes.BOOLEAN, allowNull: false, defaultValue: false },
      },
      {
        tableName: "users",
        sequelize,
        timestamps: true,
      }
    );
  }
}
