import { Model, DataTypes, Optional, Sequelize } from 'sequelize';

interface ServiceTypeAttributes {
  id: number;
  name: string;
  description?: string | null;
}

interface ServiceTypeCreationAttributes extends Optional<ServiceTypeAttributes, 'id' | 'description'> {}

export default class ServiceType extends Model<ServiceTypeAttributes, ServiceTypeCreationAttributes>
  implements ServiceTypeAttributes {
  public id!: number;
  public name!: string;
  public description!: string | null;

  static initModel(sequelize: Sequelize) {
    ServiceType.init(
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true,
        },
        name: {
          type: DataTypes.STRING,
          allowNull: false,
          unique: true,
        },
        description: {
          type: DataTypes.STRING,
          allowNull: true,
        },
      },
      {
        tableName: 'service_types',
        sequelize,
        timestamps: true,
      }
    );
  }
}
