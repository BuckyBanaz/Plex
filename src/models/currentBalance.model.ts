import { DataTypes, Model, Sequelize, Optional } from 'sequelize';
import User from './user.model';

interface CurrentBalanceAttributes {
  id: number;
  userId: number;
  balance: number;
  createdAt?: Date;
  updatedAt?: Date;
}

interface CurrentBalanceCreationAttributes extends Optional<CurrentBalanceAttributes, 'id' | 'balance'> {}

class CurrentBalance extends Model<CurrentBalanceAttributes, CurrentBalanceCreationAttributes>
  implements CurrentBalanceAttributes {
  public id!: number;
  public userId!: number;
  public balance!: number;

  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize) {
    CurrentBalance.init(
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
        balance: {
          type: DataTypes.FLOAT,
          defaultValue: 0,
          allowNull: false,
        },
      },
      {
        tableName: 'current_balances',
        sequelize,
      }
    );
  }

  static associate() {
    CurrentBalance.belongsTo(User, { foreignKey: 'userId', as: 'balanceUser' });
  }
}

export default CurrentBalance;
