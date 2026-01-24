import admin from "firebase-admin";
import fs from "fs";
import path from "path";

const configPath = path.join(__dirname, "../../src/config/config.json");
const config = fs.existsSync(configPath)
  ? JSON.parse(fs.readFileSync(configPath, "utf-8"))
  : {};

let app: admin.app.App | null = null;

export function initFirebase() {
  if (app) return app;

  // First check if credentials are already in config.json
  if (config.type === "service_account" && config.project_id) {
    app = admin.initializeApp({
      credential: admin.credential.cert(config as admin.ServiceAccount),
    });
    console.info("✅ Firebase Admin initialized from config.json");
    return app;
  }

  // Otherwise check for service account path
  const serviceAccountPath =
    process.env.FIREBASE_SERVICE_ACCOUNT_PATH || config.FIREBASE_SERVICE_ACCOUNT_PATH;

  if (!serviceAccountPath) {
    console.warn("⚠️ Firebase service account not configured. Push notifications disabled.");
    return null;
  }

  const serviceAccount = JSON.parse(fs.readFileSync(serviceAccountPath, "utf-8"));

  app = admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });

  console.info("✅ Firebase Admin initialized from file");
  return app;
}

export function getMessaging() {
  if (!admin.apps.length) initFirebase();
  return admin.messaging();
}
