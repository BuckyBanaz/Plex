import { Sequelize } from "sequelize";
import Shipment from "./shipment.model";
import Trip from "./trip.model";
import Vehicle from "./vehicle.model";
import ServiceType from "./serviceType.model";
import IntegrationToken from "./integrationToken.model";
import User from "./user.model";
import CorporateDetail from "./corporate.model";
import UserLocation from "./userLocation.model";
import UserLocationHistory from "./userLocationHistory.model";
import CurrentBalance from "./currentBalance.model";
import BalanceHistory from "./balanceHistory.model";
import UserAddress from './userAddress.model';
import Kyc from "./driverKyc.model";

export function initModels(sequelize: Sequelize) {
  // -------------------------
  // Initialize Models
  // -------------------------
  User.initModel(sequelize);
  CorporateDetail.initModel(sequelize);
  Vehicle.initModel(sequelize);
  ServiceType.initModel(sequelize);
  Shipment.initModel(sequelize);
  Trip.initModel(sequelize);
  IntegrationToken.initModel(sequelize);
  UserLocation.initModel(sequelize);
  UserLocationHistory.initModel(sequelize);
  CurrentBalance.initModel(sequelize);
  BalanceHistory.initModel(sequelize);
  UserAddress.initModel(sequelize);
  Kyc.initModel(sequelize);

  // -------------------------
  // User Associations
  // -------------------------
  User.hasOne(CorporateDetail, { foreignKey: "userId", as: "corporateDetail" });
  CorporateDetail.belongsTo(User, { foreignKey: "userId", as: "corporateUser" });

  User.hasOne(Vehicle, { foreignKey: "driverId", as: "vehicle" });
  Vehicle.belongsTo(User, { foreignKey: "driverId", as: "driverUser" });

  User.hasOne(UserLocation, { foreignKey: "userId", as: "currentLocation" });
  UserLocation.belongsTo(User, { foreignKey: "userId", as: "currentLocationUser" });

  User.hasMany(UserLocationHistory, { foreignKey: "userId", as: "locationHistory" });
  UserLocationHistory.belongsTo(User, { foreignKey: "userId", as: "historyUser" });

  User.hasOne(CurrentBalance, { foreignKey: "userId", as: "currentBalance" });
  CurrentBalance.belongsTo(User, { foreignKey: "userId", as: "currentBalanceUser" });

  User.hasMany(BalanceHistory, { foreignKey: "userId", as: "balanceHistory" });
  BalanceHistory.belongsTo(User, { foreignKey: "userId", as: "balanceHistoryUser" });

  User.hasMany(UserAddress, { foreignKey: "userId", as: "addresses" });
  UserAddress.belongsTo(User, { foreignKey: "userId", as: "addressUser" });

  User.hasOne(Kyc, { foreignKey: "driverId", as: "kyc" });
  Kyc.belongsTo(User, { foreignKey: "driverId", as: "driver" });

  // -------------------------
  // Shipment Associations
  // -------------------------
  Shipment.belongsTo(User, { foreignKey: "userId", as: "user" });
  Shipment.belongsTo(User, { foreignKey: "driverId", as: "driver" });
  Shipment.belongsTo(Vehicle, { foreignKey: "vehicleId", as: "vehicle" });

  // -------------------------
  // Trip & Other Associations
  // -------------------------
  Trip.associate?.();
  UserLocation.associate?.();
  UserLocationHistory.associate?.();
  CurrentBalance.associate?.();
  BalanceHistory.associate?.();
  UserAddress.associate();
}

export {
  Shipment,
  Trip,
  Vehicle,
  ServiceType,
  IntegrationToken,
  User,
  CorporateDetail,
  UserLocation,
  UserLocationHistory,
  CurrentBalance,
  BalanceHistory,
  Kyc,
};
