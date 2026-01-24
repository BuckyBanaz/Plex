import { Express } from "express";
import swaggerJSDoc from "swagger-jsdoc";
import swaggerUi from "swagger-ui-express";
import path from "path";
import fs from 'fs';

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));

export function setupSwagger(app: Express) {
const isProduction = config.NODE_ENV.toLowerCase() === "production";

  console.log(" Running in:", isProduction ? "PRODUCTION" : "LOCAL");

  // Only scan src/**/*.ts to avoid old dist files
  const apisPath = [path.join(process.cwd(), "src/**/*.ts")];

  console.log(" Swagger scanning paths:", apisPath);

  const options = {
    definition: {
      openapi: "3.1.0",
      info: {
        title: "Node Plex Backend API",
        version: "1.0.0",
        description: "API documentation for Node Plex Backend",
      },
      servers: [
        {
          url: isProduction
            ? config.LIVE_URL || "https://p2dev10.in"
            : "http://localhost:3000",
        },
      ],
    },
    apis: apisPath,
  };

  const swaggerSpec = swaggerJSDoc(options);
  app.use("/api-docs", swaggerUi.serve, swaggerUi.setup(swaggerSpec));

  console.log(" Swagger docs ready at /api-docs");
}



