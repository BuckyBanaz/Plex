import { Model, DataTypes, Optional, Sequelize } from "sequelize";

interface AdminAttributes {
  id: number;
  name: string;
  email: string;
  password: string;
  role: string; // e.g., super_admin, support_admin, kyc_admin
  createdAt?: Date;
  updatedAt?: Date;
}

interface AdminCreationAttributes extends Optional<AdminAttributes, "id" | "role"> {}

export default class Admin
  extends Model<AdminAttributes, AdminCreationAttributes>
  implements AdminAttributes
{
  public id!: number;
  public name!: string;
  public email!: string;
  public password!: string;
  public role!: string;

  public readonly createdAt!: Date;
  public readonly updatedAt!: Date;

  static initModel(sequelize: Sequelize) {
    Admin.init(
      {
        id: { type: DataTypes.INTEGER, primaryKey: true, autoIncrement: true },
        name: { type: DataTypes.STRING, allowNull: false },
        email: { type: DataTypes.STRING, allowNull: false, unique: true },
        password: { type: DataTypes.STRING, allowNull: false },
        role: {
          type: DataTypes.STRING,
          allowNull: false,
          defaultValue: "admin",
        }
      },
      {
        tableName: "admins",
        sequelize,
        timestamps: true,
      }
    );
  }
}
