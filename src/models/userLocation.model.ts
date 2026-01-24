import { Model, DataTypes, Sequelize, Optional } from 'sequelize';
import User from './user.model';

export interface UserLocationAttributes {
  id: number;
  userId: number;
  latitude: number;
  longitude: number;
  accuracy?: number;
  heading?: number;
  speed?: number;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface UserLocationCreationAttributes
  extends Optional<UserLocationAttributes, 'id'> {}

export default class UserLocation
  extends Model<UserLocationAttributes, UserLocationCreationAttributes>
  implements UserLocationAttributes
{
  public id!: number;
  public userId!: number;
  public latitude!: number;
  public longitude!: number;
  public accuracy?: number;
  public heading?: number;
  public speed?: number;
  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize) {
    UserLocation.init(
      {
        id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
        userId: {
          type: DataTypes.INTEGER,
          allowNull: false,
          references: { model: 'users', key: 'id' },
          onDelete: 'CASCADE',
          field: 'user_id',
        },
        latitude: { type: DataTypes.FLOAT, allowNull: false },
        longitude: { type: DataTypes.FLOAT, allowNull: false },
        accuracy: { type: DataTypes.FLOAT, allowNull: true },
        heading: { type: DataTypes.FLOAT, allowNull: true },
        speed: { type: DataTypes.FLOAT, allowNull: true },
      },
      {
        tableName: 'user_locations',
        sequelize,
        timestamps: true,
      }
    );
  }

  static associate() {
    UserLocation.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}
