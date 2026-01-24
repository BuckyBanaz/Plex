import { Model, DataTypes, Optional, Sequelize } from 'sequelize';
import Shipment from './shipment.model';
import Vehicle from './vehicle.model';

interface TripAttributes {
  id: number;
  shipmentId: number;
  vehicleId: number;
  startLocation: string;
  endLocation: string;
  distance: number;
  status: string;
  startedAt?: Date | null;
  endedAt?: Date | null;
}

interface TripCreationAttributes extends Optional<TripAttributes, 'id' | 'status' | 'startedAt' | 'endedAt'> {}

export default class Trip extends Model<TripAttributes, TripCreationAttributes> implements TripAttributes {
  public id!: number;
  public shipmentId!: number;
  public vehicleId!: number;
  public startLocation!: string;
  public endLocation!: string;
  public distance!: number;
  public status!: string;
  public startedAt!: Date | null;
  public endedAt!: Date | null;

  static initModel(sequelize: Sequelize) {
    Trip.init(
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true,
        },
        shipmentId: {
          type: DataTypes.INTEGER,
          allowNull: false,
        },
        vehicleId: {
          type: DataTypes.INTEGER,
          allowNull: false,
        },
        startLocation: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        endLocation: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        distance: {
          type: DataTypes.FLOAT,
          allowNull: false,
        },
        status: {
          type: DataTypes.STRING,
          allowNull: false,
          defaultValue: 'scheduled',
        },
        startedAt: {
          type: DataTypes.DATE,
          allowNull: true,
        },
        endedAt: {
          type: DataTypes.DATE,
          allowNull: true,
        },
      },
      {
        tableName: 'trips',
        sequelize,
        timestamps: true,
      }
    );
  }

  static associate() {
    Trip.belongsTo(Shipment, { foreignKey: 'shipmentId' });
    Trip.belongsTo(Vehicle, { foreignKey: 'vehicleId' });
  }
}
