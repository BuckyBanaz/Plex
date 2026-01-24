import { DataTypes } from "sequelize";
import { sequelize } from "../db/database";

export const StripeWebhookEvent = sequelize.define(
  "stripe_webhook_events",
  {
    id: {
      type: DataTypes.STRING,
      primaryKey: true,
    },
  },
  { timestamps: true }
);
