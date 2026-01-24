import { Model, DataTypes, Sequelize, Optional } from 'sequelize';
import User from './user.model';

export interface UserAddressAttributes {
  id: number;
  userId: number;
  address: string;
  addressAs: string; // Home, Work, Other
  landmark?: string;
  locality?: string;
  latitude: number;
  longitude: number;
  isDefault: boolean;
  createdAt?: Date;
  updatedAt?: Date;
}

export interface UserAddressCreationAttributes
  extends Optional<UserAddressAttributes, 'id' | 'isDefault' | 'landmark' | 'locality'> {}

export default class UserAddress
  extends Model<UserAddressAttributes, UserAddressCreationAttributes>
  implements UserAddressAttributes
{
  public id!: number;
  public userId!: number;
  public address!: string;
  public addressAs!: string;
  public landmark?: string;
  public locality?: string;
  public latitude!: number;
  public longitude!: number;
  public isDefault!: boolean;

  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize) {
    UserAddress.init(
      {
        id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
        userId: {
          type: DataTypes.INTEGER,
          allowNull: false,
          references: { model: 'users', key: 'id' },
          onDelete: 'CASCADE',
          field: 'user_id',
        },
        address: { type: DataTypes.STRING, allowNull: false },
        addressAs: { type: DataTypes.STRING, allowNull: false },
        landmark: { type: DataTypes.STRING, allowNull: true },
        locality: { type: DataTypes.STRING, allowNull: true },
        latitude: { type: DataTypes.FLOAT, allowNull: false },
        longitude: { type: DataTypes.FLOAT, allowNull: false },
        isDefault: { type: DataTypes.BOOLEAN, defaultValue: false },
      },
      {
        tableName: 'user_addresses',
        sequelize,
        timestamps: true,
      }
    );
  }

  static associate() {
    UserAddress.belongsTo(User, { foreignKey: 'userId', as: 'user' });
  }
}
