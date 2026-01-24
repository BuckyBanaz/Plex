// models/tempRegistration.model.ts
import { DataTypes, Model } from "sequelize";
import { sequelize } from "../db/database";

class TempRegistration extends Model {
  declare key: string;
  declare data: any;
  declare expiresAt: Date;
}

TempRegistration.init(
  {
    key: {
      type: DataTypes.STRING,
      primaryKey: true,
    },
    data: {
      type: DataTypes.JSONB,
      allowNull: false,
    },
    expiresAt: {
      type: DataTypes.DATE,
      allowNull: false,
    },
  },
  {
    sequelize,
    tableName: "temp_registrations",
    timestamps: false,
  }
);

export default TempRegistration;
