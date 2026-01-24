// utils/sms.service.ts
import twilio from "twilio";
import fs from "fs";

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));
const client = twilio(config.TWILIO_ACCOUNT_SID, config.TWILIO_AUTH_TOKEN);

// ==========================
// Generate OTP
// ==========================
export async function generateOTP(key: string, keyType: string): Promise<number> {
  // Generate 6-digit OTP
  const otp = Math.floor(100000 + Math.random() * 900000);

  // You can later store it in Redis or DB for verification if needed.
  console.log(`[OTP Generated] Key: ${key}, Type: ${keyType}, OTP: ${otp}`);
  return otp;
}

// ==========================
// Send SMS using Twilio
// ==========================
export async function sendSms(to: string, message: string) {
  try {
    const result = await client.messages.create({
      body: message,
      from: config.TWILIO_PHONE_NUMBER, // Your Twilio verified number
      to,
    });
    console.log(` SMS sent to ${to}, SID: ${result.sid}`);
  } catch (err: any) {
    console.error(" Error sending SMS:", err.message);
    throw err;
  }
}
