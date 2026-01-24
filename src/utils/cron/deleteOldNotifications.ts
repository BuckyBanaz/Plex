import cron from "node-cron";
import { Op } from "sequelize";
import DriverNotification from "../../models/driverNotification.model";

cron.schedule("*/5 * * * *", async () => {
  // runs every 5 minutes
  console.log("Cron-Job =========> Start")
  const now = new Date();
  await DriverNotification.destroy({
    where: {
      expiresAt: { [Op.lt]: now }
    }
  });

  console.log("🗑 Old notifications cleaned");
});
