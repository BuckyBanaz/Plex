import { getMessaging } from "./firebase";
import admin from "firebase-admin";

export async function sendFcmToToken(token: string, payload: admin.messaging.Message) {
  try {
    const messaging = getMessaging();
    if (!messaging) {
      console.warn("FCM not initialized, skipping notification");
      return null;
    }
    const res = await messaging.send({ token, ...payload } as any);
    return res;
  } catch (err: any) {
    console.error("❌ FCM send error:", err.message || err);
    return null;
  }
}
