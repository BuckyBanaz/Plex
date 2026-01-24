import { Router, Request, Response } from "express";
import path from "path";
import logger from "../utils/logger";

const router = Router();

/**
 * @swagger
 * tags:
 *   name: Logs
 *   description: API to download server logs
 */

/**
 * @swagger
 * /api-logs/tst:
 *   get:
 *     summary: Download API logs
 *     tags: [Logs]
 *     responses:
 *       200:
 *         description: Logs file downloaded successfully
 *       500:
 *         description: Could not download logs
 */
router.get("/tst", (req: Request, res: Response) => {
  const filePath = path.join(__dirname, "../../app/data/logs/app.log");

  logger.info(`Logs download requested by IP: ${req.ip} | URL: ${req.originalUrl}`);

  res.download(filePath, "api-logs.log", (err) => {
    if (err) {
      logger.error(`Failed to download logs for IP: ${req.ip} | Error: ${err.message}`, err);
      res.status(500).json({ error: "Could not download logs" });
    } else {
      logger.info(`Logs downloaded successfully by IP: ${req.ip}`);
    }
  });
});

export default router;
