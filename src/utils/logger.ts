import { createLogger, format, transports } from "winston";
import path from "path";
import fs from "fs";

// Ensure logs folder exists
const logDir = path.join(__dirname, "../../app/data/logs");
if (!fs.existsSync(logDir)) {
  fs.mkdirSync(logDir, { recursive: true });
}

const logger = createLogger({
  level: "info",
  format: format.combine(
    format.timestamp({ format: "YYYY-MM-DD HH:mm:ss" }),
    format.printf(
      ({ level, message, timestamp }) => `[${timestamp}] ${level.toUpperCase()}: ${message}`
    )
  ),
  transports: [
    new transports.File({
      filename: path.join(logDir, "app.log"),
      maxsize: 5 * 1024 * 1024, // 5 MB rotation
      maxFiles: 5,
    }),
    new transports.Console(), // keep console logs too
  ],
});

export default logger;
