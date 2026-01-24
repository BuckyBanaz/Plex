import { Model, DataTypes, Optional, Sequelize } from 'sequelize';

interface IntegrationTokenAttributes {
  id: number;
  provider: string;
  token: string;
  expiresAt: Date;
  createdAt?: Date;
  updatedAt?: Date;
}

interface IntegrationTokenCreationAttributes extends Optional<IntegrationTokenAttributes, 'id'> {}

export default class IntegrationToken extends Model<IntegrationTokenAttributes, IntegrationTokenCreationAttributes>
  implements IntegrationTokenAttributes {
  public id!: number;
  public provider!: string;
  public token!: string;
  public expiresAt!: Date;

  static initModel(sequelize: Sequelize) {
    IntegrationToken.init(
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true,
        },
        provider: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        token: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        expiresAt: {
          type: DataTypes.DATE,
          allowNull: false,
        },
      },
      {
        tableName: 'integration_tokens',
        sequelize,
        timestamps: true,
      }
    );
  }
}
