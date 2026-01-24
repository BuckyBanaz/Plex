import { DataTypes, Model, Sequelize, Optional } from 'sequelize';
import User from './user.model';

interface BalanceHistoryAttributes {
  id: number;
  userId: number;
  amount: number;
  type: 'credit' | 'debit';
  description?: string;
  createdAt?: Date;
  updatedAt?: Date;
}

interface BalanceHistoryCreationAttributes extends Optional<BalanceHistoryAttributes, 'id' | 'description'> {}

class BalanceHistory extends Model<BalanceHistoryAttributes, BalanceHistoryCreationAttributes>
  implements BalanceHistoryAttributes {
  public id!: number;
  public userId!: number;
  public amount!: number;
  public type!: 'credit' | 'debit';
  public description?: string;

  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize) {
    BalanceHistory.init(
      {
        id: {
          type: DataTypes.INTEGER,
          autoIncrement: true,
          primaryKey: true,
        },
        userId: {
          type: DataTypes.INTEGER,
          allowNull: false,
        },
        amount: {
          type: DataTypes.FLOAT,
          allowNull: false,
        },
        type: {
          type: DataTypes.ENUM('credit', 'debit'),
          allowNull: false,
        },
        description: {
          type: DataTypes.STRING,
          allowNull: true,
        },
      },
      {
        tableName: 'balance_histories',
        sequelize,
      }
    );
  }

  static associate() {
    BalanceHistory.belongsTo(User, { foreignKey: 'userId', as: 'historyBalanceUser' });
  }
}

export default BalanceHistory;
