import logger from '../utils/logger'; // ✅ Import Winston logger

// Simple in-memory OTP store
interface OTPEntry {
  otp: string;
  expiresAt: number;
}

const otpStore: Record<string, OTPEntry> = {};

// Generate OTP (6-digit)
export function generateOTP(key: string, type: 'email' | 'mobile'): string {
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const expiresAt = Date.now() + 5 * 60 * 1000; // 5 minutes expiry

  otpStore[key] = { otp, expiresAt };

  logger.info(`[OTP Generated] Type: ${type}, Key: ${key}, OTP: ${otp}`);
  return otp;
}

// Verify OTP
export function verifyOTP(key: string, otp: string): boolean {
  const entry = otpStore[key];

  if (!entry) {
    logger.warn(`[OTP Verification Failed] No OTP found for Key: ${key}`);
    return false;
  }

  if (entry.otp === otp && entry.expiresAt > Date.now()) {
    delete otpStore[key]; // remove after verification
    logger.info(`[OTP Verified Successfully] Key: ${key}`);
    return true;
  } else {
    logger.warn(`[OTP Verification Failed] Invalid or expired OTP for Key: ${key}`);
    return false;
  }
}
