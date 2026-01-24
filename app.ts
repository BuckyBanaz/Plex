import express, { Request, Response, NextFunction } from "express";
import dotenv from "dotenv";
import cors from "cors";
import routes from "./src/routes";
import { apiLogger } from "./src/middleware/apiLogger";
import logger from "./src/utils/logger";
import { setupSwagger } from "./src/utils/swagger";
import { serveWellKnown } from './src/middleware/wellKnown';

dotenv.config();

const app = express();

// ============================
// 1️⃣ Stripe Webhook Route (RAW BODY ONLY)
// ============================
// ⚠️ This MUST be **before** express.json() / bodyParser middleware
app.use(
  "/api/stripe",
  require("./src/routes/stripeWebhook.routes").default
);


// Register middleware
serveWellKnown(app);

// ============================
// 2️⃣ Other middleware
// ============================
// ✅ Enable CORS for all routes
app.use(
  cors({
    origin: "*", // or specify your Swagger UI domain if hosted elsewhere
    methods: ["GET", "POST", "PUT", "PATCH", "DELETE"],
    allowedHeaders: ["Content-Type", "Authorization", "token", "lang_id"],
  })
);// CORS for all other routes
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// API logger
app.use(apiLogger);

// ============================
// 3️⃣ Swagger Docs
// ============================
setupSwagger(app);

// ============================
// 4️⃣ Mount main app routes
// ============================
app.use("/", routes);

// ============================
// 5️⃣ Health Check
// ============================
app.get("/", (req: Request, res: Response) => {
  logger.info(`Health check requested from IP: ${req.ip}`);
  res.send("PLEX API is running!");
});

// ============================
// 6️⃣ Global Error Handler
// ============================
app.use(
  (err: any, req: Request, res: Response, next: NextFunction) => {
    logger.error(`Unhandled error: ${err.message}`, err);
    res.status(500).json({ error: "Internal server error" });
  }
);

export default app;
