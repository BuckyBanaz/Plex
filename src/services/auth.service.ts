import bcrypt from "bcrypt";
import crypto from "crypto";
import jwt from "jsonwebtoken";
import fs from "fs";
import { sequelize } from "../db/database";
import logger from "../utils/logger";
import { sendSms } from "../utils/sms.service";
import { generateOTP, verifyOTP } from "../utils/otp.service";
import { sendOtpEmail } from "../utils/sendEmail";
import User from "../models/user.model";
import CorporateDetail from "../models/corporate.model";
import Vehicle from "../models/vehicle.model";
import TempRegistration from "../models/tempRegistration.model";
import CurrentBalance from "../models/currentBalance.model";
import { UserLocation } from "../models";
import  UserAddress  from "../models/userAddress.model"
import { UpdatedAt } from "sequelize-typescript";
import { AppError } from "../utils/AppError";
import Kyc from "../models/driverKyc.model";

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));
const JWT_SECRET = config.JWT_SECRET || "secret123";

// ==========================================================
// 🔹 Helpers
// ==========================================================
function normalizeMobile(mobile: string) {
  let digits = mobile.replace(/\D/g, "");
  if (digits.length > 10) digits = digits.slice(-10);
  return digits;
}

function validateEmail(email: string) {
  return /^\S+@\S+\.\S+$/.test(email);
}

function validateMobile(mobile: string) {
  return /^\d{10}$/.test(mobile);
}


// ==========================================================
// 🔹 Register Individual
// ==========================================================
export async function registerIndividual(
  name: string,
  email: string,
  mobile: string,
  password: string,
  deviceId: string,
  otpType: "email" | "mobile",
  fcmToken: string
) {
  if (!name?.trim()) throw new AppError("Name is required.");
  if (!email?.trim()) throw new AppError("Email is required.");
  if (!mobile?.trim()) throw new AppError("Mobile number is required.");
  if (!password?.trim()) throw new AppError("Password is required.");
  if (!deviceId?.trim()) throw new AppError("Device ID is required.");
  if(!fcmToken?.trim()) throw new AppError("fcmToken is required")

  if (!validateEmail(email)) throw new AppError("Invalid email format.");
  if (!validateMobile(mobile)) throw new AppError("Invalid mobile number format.");
  if (password.length < 6) throw new AppError("Password must be at least 6 characters.");

  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) throw new AppError("Email already registered.");

  const key = otpType === "mobile" ? `mobile:${normalizeMobile(mobile)}` : `email:${email.toLowerCase()}`;

  await TempRegistration.destroy({ where: { key } });

  await TempRegistration.create({
    key,
    data: { name, email, mobile, password, deviceId, userType: "individual", fcmToken },
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  const otp = await generateOTP(key, otpType);

  if (otpType === "email") {
    await sendOtpEmail(email, "Verify Your Email", `Your OTP code is ${otp}`);
  } else {
    await sendSms(mobile, `Your OTP is ${otp}`);
  }

  const tempToken = jwt.sign({ key, userType: "individual" }, JWT_SECRET, { expiresIn: "10m" });

  return { success: true, message: `OTP sent successfully to your ${otpType}.`, tempToken };
}

// ==========================================================
// 🔹 Register Corporate
// ==========================================================
export async function registerCorporate(data: any, otpType: "email" | "mobile" = "email") {
  const { name, email, mobile, password, companyName, sector, commercialRegNo, deviceId } = data;

  if (!name?.trim()) throw new AppError("Name is required.");
  if (!email?.trim()) throw new AppError("Email is required.");
  if (!mobile?.trim()) throw new AppError("Mobile number is required.");
  if (!password?.trim()) throw new AppError("Password is required.");
  if (!companyName?.trim()) throw new AppError("Company name is required.");
  if (!sector?.trim()) throw new AppError("Sector is required.");
  if (!commercialRegNo?.trim()) throw new AppError("Commercial registration number is required.");
  if (!deviceId?.trim()) throw new AppError("Device ID is required.");

  if (!validateEmail(email)) throw new AppError("Invalid email format.");
  if (!validateMobile(mobile)) throw new AppError("Invalid mobile number format.");

  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) throw new AppError("Corporate email already registered.");

  const key = otpType === "mobile" ? `mobile:${normalizeMobile(mobile)}` : `email:${email.toLowerCase()}`;

  await TempRegistration.destroy({ where: { key } });

  await TempRegistration.create({
    key,
    data: { ...data, userType: "corporate" },
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  const otp = await generateOTP(key, otpType);
  if (otpType === "email") {
    await sendOtpEmail(email, "Verify Corporate Account", `Your OTP is ${otp}`);
  } else {
    await sendSms(mobile, `Your OTP is ${otp}`);
  }

  const tempToken = jwt.sign({ key, userType: "corporate" }, JWT_SECRET, { expiresIn: "10m" });
  return { success: true, message: `OTP sent successfully to your ${otpType}.`, tempToken };
}


// ==========================================================
// 🔹 Register Guest
// ==========================================================
export async function registerGuest(
  name: string,
  email: string,
  mobile: string,
  deviceId: string,
  otpType: "email" | "mobile" = "email"
) {
  if (!name || (!email && !mobile && !deviceId))
    throw new Error("Name and email/mobile/deviceId required");

  const key =
    otpType === "mobile"
      ? `mobile:${normalizeMobile(mobile)}`
      : `email:${email.toLowerCase()}`;

  await TempRegistration.destroy({ where: { key } });

  await TempRegistration.create({
    key,
    data: { name, email, mobile, deviceId, userType: "guest" },
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  const otp = await generateOTP(key, otpType);
  if (otpType === "email") await sendOtpEmail(email, "Verify Guest Account", `Your OTP is ${otp}`);
  else await sendSms(mobile, `Your OTP is ${otp}`);

  const tempToken = jwt.sign({ key, userType: "guest" }, JWT_SECRET, { expiresIn: "10m" });
  return { success: true, message: `OTP sent successfully to your ${otpType}.`, tempToken };
}

// ==========================================================
// 🔹 Register Driver
// ==========================================================
export async function registerDriver(input: any, otpType: "email" | "mobile" = "email") {
  const { name, email, mobile, password, deviceId, fcmToken } = input;

  if (!name || !email || !mobile || !password || !deviceId || !fcmToken)
    throw new Error("Missing required driver registration fields");

  if (!validateEmail(email)) throw new AppError("Invalid email format.");
  if (!validateMobile(mobile)) throw new AppError("Invalid mobile number format.");

  const existingUser = await User.findOne({ where: { email } });
  if (existingUser) throw new AppError("Driver already registered.");

  const key = otpType === "mobile" ? `mobile:${normalizeMobile(mobile)}` : `email:${email.toLowerCase()}`;
  await TempRegistration.destroy({ where: { key } });

  await TempRegistration.create({
    key,
    data: { ...input, userType: "driver" },
    expiresAt: new Date(Date.now() + 10 * 60 * 1000),
  });

  const otp = await generateOTP(key, otpType);
  if (otpType === "email") await sendOtpEmail(email, "Verify Driver Account", `Your OTP is ${otp}`);
  else await sendSms(mobile, `Your OTP is ${otp}`);

  const tempToken = jwt.sign({ key, userType: "driver" }, JWT_SECRET, { expiresIn: "10m" });
  return { success: true, message: `OTP sent successfully to your ${otpType}.`, tempToken };
}

// ==========================================================
// 🔹 Verify OTP & Create User
// ==========================================================
export async function verifyOtpAndCreateUser(keyType: string, keyValue: string, otp: string) {
  // --- Basic validations ---
  if (!keyType?.trim()) throw new AppError("Key type is required.");
  if (!keyValue?.trim()) throw new AppError("Key value is required.");
  if (!otp?.trim()) throw new AppError("OTP is required.");

  const key = `${keyType}:${keyValue}`;
  const temp = await TempRegistration.findOne({ where: { key } });
  if (!temp) throw new AppError("Invalid or expired registration session.");

  const valid = await verifyOTP(key, otp);
  if (!valid) throw new AppError("Invalid or expired OTP.");

  const { data } = temp;
  const t = await sequelize.transaction();

  try {
    // --- Additional field validation before creating user ---
    if (!data.name?.trim()) throw new AppError("Name is required.");
    if (!data.userType?.trim()) throw new AppError("User type is required.");

    // If email or mobile required based on keyType
    if (keyType === "email" && !data.email?.trim())
      throw new AppError("Email is required for email verification.");
    if (keyType === "mobile" && !data.mobile?.trim())
      throw new AppError("Mobile number is required for mobile verification.");


    const hashedPassword = data.password ? await bcrypt.hash(data.password, 10) : null;

    // --- Create user ---
    const newUser = await User.create(
      {
        name: data.name,
        email: data.email,
        mobile: data.mobile,
        password: hashedPassword,
        deviceId: data.deviceId,
        userType: data.userType,
        isEmailVerified: keyType === "email",
        isMobileVerified: keyType === "mobile",
        fcmToken: data.fcmToken,
      },
      { transaction: t }
    );

    if (keyType === "email") newUser.isEmailVerified = true;
    if (keyType === "mobile") newUser.isMobileVerified = true;
    await newUser.save({ transaction: t });

    // --- Save extra details ---
    if (data.userType === "corporate") {
      await CorporateDetail.create({ userId: newUser.id, ...data }, { transaction: t });
    }

    // --- Initialize balance ---
    const currentBalance = await CurrentBalance.create(
      { userId: newUser.id, balance: 0 },
      { transaction: t }
    );

    await t.commit();
    await temp.destroy();

    const token = jwt.sign(
      { id: newUser.id, userType: newUser.userType },
      JWT_SECRET,
      { expiresIn: "1h" }
    );

    // --- Build response ---
    const userResponse: any = {
      id: newUser.id,
      name: newUser.name,
      email: newUser.email,
      mobile: newUser.mobile,
      userType: newUser.userType,
      isEmailVerified: newUser.isEmailVerified,
      isMobileVerified: newUser.isMobileVerified,
      createdAt: newUser.createdAt,
      updatedAt: newUser.updatedAt,
    };


        // Attach initial balance
    userResponse.currentBalance = {
      id: currentBalance.id,
      balance: currentBalance.balance,
      createdAt: currentBalance.createdAt,
      updatedAt: currentBalance.updatedAt,
    };

    // Drivers will complete KYC later
    if (newUser.userType === "driver") {
      userResponse.kycStatus = "pending";
    }

    return { success: true, message: "OTP verified successfully.", user: userResponse, token };
  } catch (err) {
    await t.rollback();
    throw new Error("Error while creating user: " + (err as Error).message);
  }
}


// ==========================================================
// 🔹 Login
// ==========================================================
export async function login(email: string, password: string) {
  // --- Validation section ---
  if (!email?.trim()) throw new Error("Email is required.");
  if (!password?.trim()) throw new Error("Password is required.");
  if (!validateEmail(email)) throw new Error("Invalid email format.");

  // --- Fetch user with location + addresses ---
  const user = await User.findOne({
    where: { email },
    include: [
      { model: UserLocation, as: "currentLocation" },
      { model: UserAddress, as: "addresses" },
    ],
  });

  if (!user) throw new Error("User not found.");
  if (!user.password) throw new Error("Password not set for this user.");

  // --- Password check ---
  const valid = await bcrypt.compare(password, user.password);
  if (!valid) throw new Error("Incorrect password.");

  // --- Prepare user data ---
  const userData = user.get({ plain: true });
  delete userData.password;

  // --- Base user response ---
  const userResponse: any = {
    id: userData.id,
    name: userData.name,
    email: userData.email,
    userType: userData.userType,
    mobile: userData.mobile,
    mobileVerified: userData.isMobileVerified,
    emailVerified: userData.isEmailVerified,
    createdAt: userData.createdAt,
    updatedAt: userData.updatedAt,
  };

  // ===========================
  // DRIVER LOGIC
  // ===========================
  if (userData.userType === "driver") {
    //  Fetch KYC record safely
    const kycRecord = await Kyc.findOne({
      where: { driverId: userData.id },
    });

    let isKycVerified = false;
    let kycStatus: "pending" | "verified" | "rejected" = "pending";

    if (kycRecord) {
      kycStatus = kycRecord.verifiedStatus;
      if (kycStatus === "verified") {
        isKycVerified = true;
      }
    }

    //  Attach KYC status to response
    userResponse.kycStatus = kycStatus;

    //  Vehicle info only if KYC verified
    if (isKycVerified) {
      const vehicleInstance = await Vehicle.findOne({
        where: { driverId: userData.id },
      });

      if (vehicleInstance) {
        const v = vehicleInstance.get({ plain: true });
        userResponse.vehicle = [
          {
            id: v.id,
            type: v.type,
            licenseNo: v.licenseNo,
            createdAt: v.createdAt ?? null,
            updatedAt: v.updatedAt ?? null,
          },
        ];
      } else {
        userResponse.vehicle = [];
      }
    } else {
      userResponse.vehicle = []; // empty if KYC not verified
    }

    //  Fetch current balance
    const balanceInstance = await CurrentBalance.findOne({
      where: { userId: userData.id },
    });
    if (balanceInstance) {
      const b = balanceInstance.get({ plain: true });
      userResponse.currentBalance = {
        id: b.id,
        balance: b.balance,
        createdAt: b.createdAt,
        updatedAt: b.updatedAt,
      };
    } else {
      userResponse.currentBalance = {
        id: userData.id,
        balance: 0,
        createdAt: null,
        updatedAt: null,
      };
    }

    //  Location
    userResponse.location = userData.currentLocation
      ? {
          latitude: userData.currentLocation.latitude,
          longitude: userData.currentLocation.longitude,
          accuracy: userData.currentLocation.accuracy || 0,
          heading: userData.currentLocation.heading || 0,
          speed: userData.currentLocation.speed || 0,
          recorded_at: userData.currentLocation.createdAt,
        }
      : {
          latitude: 0,
          longitude: 0,
          accuracy: 0,
          heading: 0,
          speed: 0,
          recorded_at: null,
        };
  }

  // ===========================
  // INDIVIDUAL LOGIC
  // ===========================
  if (userData.userType === "individual") {
    const addresses = userData.addresses ?? [];

    userResponse.address =
      addresses.length > 0
        ? addresses.map((addr: any) => ({
            id: addr.id,
            address: addr.address,
            addressAs: addr.addressAs,
            landmark: addr.landmark,
            locality: addr.locality,
            isDefault: addr.isDefault,
            location: {
              latitude: addr.latitude ?? 0,
              longitude: addr.longitude ?? 0,
            },
          }))
        : null;
  }

  // ===========================
  // CORPORATE OR OTHER USERS
  // ===========================
  if (userData.userType !== "driver" && userData.userType !== "individual") {
    const address =
      userData.addresses && userData.addresses.length
        ? {
            id: userData.addresses[0].id,
            address: userData.addresses[0].address,
            addressAs: userData.addresses[0].addressAs,
            landmark: userData.addresses[0].landmark,
            locality: userData.addresses[0].locality,
            isDefault: userData.addresses[0].isDefault,
            location: {
              latitude: userData.addresses[0].latitude,
              longitude: userData.addresses[0].longitude,
            },
          }
        : null;

    userResponse.address = address;
  }

  // ===========================
  // JWT TOKEN
  // ===========================
  const token = jwt.sign(
    { id: userData.id, email: userData.email, role: userData.userType },
    config.JWT_SECRET!,
    { expiresIn: "7d" }
  );

  // ===========================
  // FINAL RESPONSE
  // ===========================
  return {
    success: true,
    message: "Login successful",
    token,
    user: userResponse,
  };
}



// ==========================================================
// 🔹 Resend OTP
// ==========================================================
export async function resendOtp(keyType: "email" | "mobile", keyValue: string) {
  if (!keyType || !keyValue) throw new Error("keyType and keyValue are required.");

  const key =
    keyType === "email" ? `email:${keyValue.toLowerCase()}` : `mobile:${normalizeMobile(keyValue)}`;

  const temp = await TempRegistration.findOne({ where: { key } });
  if (!temp) throw new Error("No registration found for this key.");

  const otp = await generateOTP(key, keyType);

  if (keyType === "email") await sendOtpEmail(keyValue, "Resend OTP", `Your new OTP is ${otp}`);
  else await sendSms(keyValue, `Your new OTP is ${otp}`);

  return `OTP resent successfully to your ${keyType}.`;
}

// ==========================================================
// 🔹 Refresh Token
// ==========================================================
export async function refreshAccessToken(token: string) {
  if (!token?.trim()) throw new Error("Refresh token is required.");

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    const user = await User.findByPk(decoded.id);
    if (!user) throw new Error("User not found.");

    const newToken = jwt.sign({ id: user.id, userType: user.userType }, JWT_SECRET, { expiresIn: "1h" });
    return { success: true, message: "Token refreshed successfully.", token: newToken };
  } catch {
    throw new Error("Invalid or expired token.");
  }
}

// Temporary token store (for production, store in DB)
const resetTokenStore: Record<string, string> = {};

/**
 * Step 1: Send reset link to email
 */
export async function forgotPassword(email: string) {
  if (!email?.trim()) throw new Error("Email is required");

  const user = await User.findOne({ where: { email } });
  if (!user) throw new Error("User not found");

  // Generate reset token
  const token = crypto.randomBytes(32).toString("hex");

  // Save token mapped to user email (temporary)
  resetTokenStore[token] = email;

  // Send link via email
  await sendOtpEmail(
    email,
    "Password Reset Request",
    `Click this link to reset your password: https://p2dev10.in/reset-password?token=${token}`
  );

  return { message: "Password reset link sent to your email" };
}

/**
 * Step 2: Verify token validity
 */
export async function verifyResetToken(token: string) {
  const email = resetTokenStore[token];
  if (!email) throw new Error("Invalid or expired token");
  return { email };
}

/**
 * Step 3: Reset password using valid token
 */
export async function resetPassword(token: string, newPassword: string, confirmPassword: string) {
  if (newPassword !== confirmPassword) throw new Error("Passwords do not match");

  const email = resetTokenStore[token];
  if (!email) throw new Error("Invalid or expired token");

  const user = await User.findOne({ where: { email } });
  if (!user) throw new Error("User not found");

  const hashed = await bcrypt.hash(newPassword, 10);
  user.password = hashed;
  await user.save();

  // Invalidate token
  delete resetTokenStore[token];

  return { message: "Password reset successfully" };
}


// ==========================
// Update FCM Token Service
// ==========================
export async function updateFcmToken(userId: string, fcmToken: string) {
  const user = await User.findByPk(userId);
  
  if (!user) {
    throw new AppError("User not found", 404);
  }

  user.fcmToken = fcmToken;
  
  await user.save();

  return { message: "FCM token updated successfully" };
}




// ==========================
// Update Online Status Service
// ==========================
export async function updateOnlineStatus(userId: string, isOnline: boolean) {
  const user = await User.findByPk(userId);

  if (!user) {
    throw new AppError("User not found", 404);
  }

  user.isOnline = isOnline;
  await user.save();

  return {
    message: `User ${isOnline ? "is now online" : "is now offline"}`,
    user,
  };
}
