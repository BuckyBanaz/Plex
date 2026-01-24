import { Model, DataTypes, Sequelize, Optional } from 'sequelize';
import User from './user.model';

export interface UserLocationHistoryAttributes {
  id: number;
  userId: number;
  latitude: number;
  longitude: number;
  recordedAt?: Date;
}

export interface UserLocationHistoryCreationAttributes
  extends Optional<UserLocationHistoryAttributes, 'id' | 'recordedAt'> {}

export default class UserLocationHistory
  extends Model<UserLocationHistoryAttributes, UserLocationHistoryCreationAttributes>
  implements UserLocationHistoryAttributes
{
  public id!: number;
  public userId!: number;
  public latitude!: number;
  public longitude!: number;
  public recordedAt!: Date;

  static initModel(sequelize: Sequelize) {
    UserLocationHistory.init(
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true,
        },
        userId: {
          type: DataTypes.INTEGER,
          allowNull: false,
          references: { model: 'users', key: 'id' },
          onDelete: 'CASCADE',
          field: 'user_id', // map camelCase to DB
        },
        latitude: {
          type: DataTypes.FLOAT,
          allowNull: false,
        },
        longitude: {
          type: DataTypes.FLOAT,
          allowNull: false,
        },
        recordedAt: {
          type: DataTypes.DATE,
          allowNull: false,
          defaultValue: DataTypes.NOW,
          field: 'recorded_at',
        },
      },
      {
        tableName: 'user_location_history',
        sequelize,
        timestamps: false,
      }
    );
  }

  static associate() {
    UserLocationHistory.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}
