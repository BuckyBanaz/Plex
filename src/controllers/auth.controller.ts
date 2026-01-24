import { Request, Response } from "express";
import * as registrationService from "../services/auth.service";
import logger from "../utils/logger";
import { generateOTP, sendSms } from "../utils/sms.service";
import { sendOtpEmail } from "../utils/sendEmail";
import { AppError } from "../utils/AppError";
import fs from "fs";

const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

// ==========================
// Helper: validate email / mobile format
// ==========================
function isValidEmail(email: string): boolean {
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

function isValidMobile(mobile: string): boolean {
  return /^[0-9]{10,15}$/.test(mobile);
}

// ==========================
// Register Individual
// ==========================
export async function registerIndividual(req: Request, res: Response) {
  try {
    const { name, email, mobile, password, deviceId, otpType, fcmToken } = req.body;
    const lang_id = req.headers.lang_id as string;
    const api_key = config.API_KEY;

    // Validation
    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!name || !email || !mobile || !password || !deviceId )
      return res
        .status(400)
        .json({
          success: false,
          message:
            "All fields (name, email, mobile, password, deviceId) are required",
        });

    if (!isValidEmail(email))
      return res
        .status(400)
        .json({ success: false, message: "Invalid email format" });
    if (!isValidMobile(mobile))
      return res
        .status(400)
        .json({ success: false, message: "Invalid mobile number format" });
    if (password.length < 6)
      return res
        .status(400)
        .json({
          success: false,
          message: "Password must be at least 6 characters long",
        });

    const { message, tempToken } = await registrationService.registerIndividual(
      name,
      email,
      mobile,
      password,
      deviceId,
      otpType,
      fcmToken
    );

    return res
      .status(201)
      .json({ success: true, message, token: tempToken, key: api_key });
  } catch (err: any) {
    if (err instanceof AppError) {
      // Known (handled) error
      return res
        .status(err.statusCode)
        .json({ success: false, message: err.message });
    }
    logger.error(`Error in registerIndividual: ${err.message}`, err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

// ==========================
// Register Corporate
// ==========================
export async function registerCorporate(req: Request, res: Response) {
  try {
    const { name, email, companyName, password, mobile, otpType } = req.body;
    const lang_id = req.headers.lang_id as string;
    const api_key = config.API_KEY;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!name || !companyName || !email || !password)
      return res
        .status(400)
        .json({
          success: false,
          message:
            "All fields (name, companyName, email, password) are required",
        });

    if (!isValidEmail(email))
      return res
        .status(400)
        .json({ success: false, message: "Invalid email format" });
    if (mobile && !isValidMobile(mobile))
      return res
        .status(400)
        .json({ success: false, message: "Invalid mobile number format" });

    const { message, tempToken } = await registrationService.registerCorporate(
      req.body,
      otpType
    );
    return res
      .status(201)
      .json({ success: true, message, token: tempToken, key: api_key });
  } catch (err: any) {
    if (err instanceof AppError) {
      // Known (handled) error
      return res
        .status(err.statusCode)
        .json({ success: false, message: err.message });
    }
    logger.error(`Error in registerCorporate: ${err.message}`, err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

// ==========================
// Register Guest
// ==========================
export async function registerGuest(req: Request, res: Response) {
  try {
    const { name, email, mobile, deviceId, otpType } = req.body;
    const lang_id = req.headers.lang_id as string;
    const api_key = config.API_KEY;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!name)
      return res
        .status(400)
        .json({ success: false, message: "Name is required" });
    if (!email && !mobile && !deviceId)
      return res
        .status(400)
        .json({
          success: false,
          message: "At least one of email, mobile or deviceId is required",
        });

    if (email && !isValidEmail(email))
      return res
        .status(400)
        .json({ success: false, message: "Invalid email format" });
    if (mobile && !isValidMobile(mobile))
      return res
        .status(400)
        .json({ success: false, message: "Invalid mobile number format" });

    const { message, tempToken } = await registrationService.registerGuest(
      name,
      email,
      mobile,
      deviceId,
      otpType
    );
    return res
      .status(201)
      .json({ success: true, message, token: tempToken, key: api_key });
  } catch (err: any) {
    if (err instanceof AppError) {
      // Known (handled) error
      return res
        .status(err.statusCode)
        .json({ success: false, message: err.message });
    }
    logger.error(`Error in registerGuest: ${err.message}`, err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

// ==========================
// Register Driver
// ==========================
export async function registerDriver(req: Request, res: Response) {
  try {
    const { name, email, password, deviceId, otpType, fcmToken } = req.body;
    const lang_id = req.headers.lang_id as string;
    const api_key = config.API_KEY;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!name || !email || !password || !deviceId)
      return res
        .status(400)
        .json({ success: false, message: "All fields are required" });

    if (!isValidEmail(email))
      return res
        .status(400)
        .json({ success: false, message: "Invalid email format" });

    const { message, tempToken } = await registrationService.registerDriver(
      req.body,
      otpType
    );
    return res
      .status(201)
      .json({ success: true, message, token: tempToken, key: api_key });
  } catch (err: any) {
    if (err instanceof AppError) {
      // Known (handled) error
      return res
        .status(err.statusCode)
        .json({ success: false, message: err.message });
    }
    logger.error(`Error in registerDriver: ${err.message}`, err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

// ==========================
// Verify OTP
// ==========================
export async function verifyOtp(req: Request, res: Response) {
  try {
    const { keyType, keyValue, otp } = req.body;
    const lang_id = req.headers.lang_id as string;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!keyType || !keyValue || !otp)
      return res
        .status(400)
        .json({
          success: false,
          message: "All fields (keyType, keyValue, otp) are required",
        });

    const { user, token } = await registrationService.verifyOtpAndCreateUser(
      keyType,
      keyValue,
      otp
    );
    res.setHeader("token", token);

    if (keyType === "email") {
      await sendOtpEmail(
        keyValue,
        "Verification Successful - PLEX",
        `Hello ${user.name || "User"}, your OTP has been verified.`
      );
    }

    return res
      .status(200)
      .json({ success: true, message: "OTP verified successfully", user });
  } catch (err: any) {
    if (err instanceof AppError) {
      // Known (handled) error
      return res
        .status(err.statusCode)
        .json({ success: false, message: err.message });
    }
    logger.error(`Error in verifyOtp: ${err.message}`, err);
    return res.status(400).json({ success: false, message: err.message });
  }
}

// ==========================
// Login
// ==========================
export async function login(req: Request, res: Response) {
  try {
    const { email, password } = req.body;
    const lang_id = req.headers.lang_id as string;
    const api_key = config.API_KEY;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!email || !password)
      return res
        .status(400)
        .json({ success: false, message: "Email and password are required" });

    if (!isValidEmail(email))
      return res
        .status(400)
        .json({ success: false, message: "Invalid email format" });

    const { token, user } = await registrationService.login(email, password);
    res.setHeader("token", token);
    return res.status(200).json({ success: true, token, key: api_key, user });
  } catch (err: any) {
    logger.error(`Login failed: ${err.message}`, err);
    return res.status(401).json({ success: false, message: err.message });
  }
}

// ==========================
// Send OTP
// ==========================
export async function sendOtpHandler(req: Request, res: Response) {
  try {
    const { keyType, keyValue } = req.body;

    if (!keyType || !keyValue)
      return res
        .status(400)
        .json({ success: false, message: "keyType and keyValue are required" });

    const key = `${keyType}:${keyValue}`;
    const otp = await generateOTP(key, keyType);

    if (keyType === "email")
      await sendOtpEmail(keyValue, "Your OTP Code", otp.toString());
    else if (keyType === "mobile")
      await sendSms(keyValue, `Your OTP is ${otp}`);

    return res
      .status(200)
      .json({ success: true, message: `OTP sent to your ${keyType}` });
  } catch (err: any) {
    if (err instanceof AppError) {
      // Known (handled) error
      return res
        .status(err.statusCode)
        .json({ success: false, message: err.message });
    }
    logger.error(`Error in sendOtpHandler: ${err.message}`);
    return res.status(500).json({ success: false, message: err.message });
  }
}

// ==========================
// Resend OTP
// ==========================
export async function resendOtpHandler(req: Request, res: Response) {
  try {
    const { keyType, keyValue } = req.body;
    const lang_id = req.headers.lang_id as string;

    if (!lang_id)
      return res
        .status(400)
        .json({ success: false, message: "lang_id header is required" });
    if (lang_id !== config.LANG_ID_ENG)
      return res
        .status(400)
        .json({ success: false, message: "Invalid lang_id" });

    if (!keyType || !keyValue)
      return res
        .status(400)
        .json({ success: false, message: "keyType and keyValue are required" });

    const message = await registrationService.resendOtp(keyType, keyValue);
    return res.status(200).json({ success: true, message });
  } catch (err: any) {
    logger.error(`Error in resendOtpHandler: ${err.message}`, err);
    return res.status(500).json({ success: false, message: err.message });
  }
}

// ==========================
// Refresh Token
// ==========================
export async function refreshTokenHandler(req: Request, res: Response) {
  try {
    const refreshToken = req.headers["token"] as string;
    if (!refreshToken)
      return res
        .status(400)
        .json({ success: false, message: "Refresh token is required" });

    const newToken = await registrationService.refreshAccessToken(refreshToken);
    return res.status(200).json({ success: true, token: newToken });
  } catch (err: any) {
    return res.status(401).json({ success: false, message: err.message });
  }
}

export async function forgotPasswordController(req: Request, res: Response) {
  try {
    const { email } = req.body;
    const response = await registrationService.forgotPassword(email);
    res.status(200).json({ success: true, ...response });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
}

export async function verifyResetTokenController(req: Request, res: Response) {
  try {
    const { token } = req.query;
    const response = await registrationService.verifyResetToken(
      token as string
    );
    res.status(200).json({ success: true, ...response });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
}

export async function resetPasswordController(req: Request, res: Response) {
  try {
    const { token, newPassword, confirmPassword } = req.body;
    const response = await registrationService.resetPassword(
      token,
      newPassword,
      confirmPassword
    );
    res.status(200).json({ success: true, ...response });
  } catch (error: any) {
    res.status(400).json({ success: false, message: error.message });
  }
}

// ==========================
// Update FCM Token
// ==========================
export async function updateFcmToken(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const { fcmToken } = req.body;
    

    if (!fcmToken) {
      return res
        .status(400)
        .json({ success: false, message: "fcmToken is required" });
    }

    const result = await registrationService.updateFcmToken(userId, fcmToken);
    

    return res.status(200).json({
      success: true,
      message: result.message,
    });
  } catch (error: any) {
    logger.error(`Error in updateFcmToken: ${error.message}`, error);
    if (error.statusCode) {
      return res
        .status(error.statusCode)
        .json({ success: false, message: error.message });
    }
    return res
      .status(500)
      .json({ success: false, message: "Internal server error" });
  }
}


// ==========================
// Update onlineStatus
// ==========================
export async function updateOnlineStatus(req: Request, res: Response) {
  try {
    const { userId } = req.params;
    const { isOnline } = req.body;

    if (typeof isOnline !== "boolean") {
      return res
        .status(400)
        .json({ success: false, message: "isOnline must be boolean" });
    }

    const result = await registrationService.updateOnlineStatus(userId, isOnline);

    return res.status(200).json({
      success: true,
      message: `User ${isOnline ? "is now online" : "is now offline"}`,
      data: result,
    });
  } catch (error: any) {
    logger?.error?.(`Error in updateOnlineStatus: ${error.message}`, error);
    if (error.statusCode) {
      return res
        .status(error.statusCode)
        .json({ success: false, message: error.message });
    }
    return res
      .status(500)
      .json({ success: false, message: "Internal server error" });
  }
}
