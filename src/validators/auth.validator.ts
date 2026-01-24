import { body, header } from "express-validator";

// Common header validations
export const headerValidation = [
  header("lang_id")
    .exists().withMessage("Missing header: lang_id")
    .notEmpty().withMessage("Header lang_id cannot be empty")
];

// INDIVIDUAL registration validation
export const validateIndividual = [
  ...headerValidation,
  body("name").trim().notEmpty().withMessage("Name is required"),
  body("email").isEmail().withMessage("Valid email is required"),
  body("mobile")
    .isLength({ min: 10, max: 15 })
    .withMessage("Mobile number must be between 10 and 15 digits"),
  body("password")
    .isLength({ min: 6 })
    .withMessage("Password must be at least 6 characters long"),
  body("deviceId").notEmpty().withMessage("Device ID is required"),
  body("otpType")
    .isIn(["email", "mobile"])
    .withMessage("otpType must be either 'email' or 'mobile'"),
];

// CORPORATE registration validation
export const validateCorporate = [
  ...headerValidation,
  body("name").notEmpty().withMessage("Name is required"),
  body("email").isEmail().withMessage("Valid email is required"),
  body("mobile").notEmpty().withMessage("Mobile number is required"),
  body("password").isLength({ min: 6 }).withMessage("Password must be at least 6 characters long"),
  body("companyName").notEmpty().withMessage("Company name is required"),
  body("sector").notEmpty().withMessage("Sector is required"),
  body("commercialRegNo").notEmpty().withMessage("Commercial registration number is required"),
  body("deviceId").notEmpty().withMessage("Device ID is required"),
  body("otpType")
    .isIn(["email", "mobile"])
    .withMessage("otpType must be either 'email' or 'mobile'"),
];

// GUEST registration validation
export const validateGuest = [
  ...headerValidation,
  body("name").notEmpty().withMessage("Name is required"),
  body("email").optional().isEmail().withMessage("Email must be valid if provided"),
  body("mobile").optional().isLength({ min: 10 }).withMessage("Mobile number must be valid"),
  body("deviceId").notEmpty().withMessage("Device ID is required"),
  body("otpType")
    .isIn(["email", "mobile"])
    .withMessage("otpType must be either 'email' or 'mobile'"),
];

// DRIVER registration validation
export const validateDriver = [
  ...headerValidation,
  body("name").notEmpty().withMessage("Name is required"),
  body("email").isEmail().withMessage("Valid email is required"),
  body("password").isLength({ min: 6 }).withMessage("Password must be at least 6 characters long"),
  body("mobile").notEmpty().withMessage("Mobile number is required"),
  body("deviceId").notEmpty().withMessage("Device ID is required"),
  body("otpType")
    .isIn(["email", "mobile"])
    .withMessage("otpType must be either 'email' or 'mobile'"),
];

// OTP Verification
export const validateVerifyOtp = [
  ...headerValidation,
  body("keyType")
    .isIn(["email", "mobile"])
    .withMessage("keyType must be either 'email' or 'mobile'"),
  body("keyValue").notEmpty().withMessage("keyValue is required"),
  body("otp").isLength({ min: 4, max: 8 }).withMessage("OTP must be between 4 to 8 digits"),
];

// Login
export const validateLogin = [
  ...headerValidation,
  body("email").isEmail().withMessage("Valid email is required"),
  body("password").notEmpty().withMessage("Password is required"),
];

// Send OTP
export const validateSendOtp = [
  body("keyType")
    .isIn(["email", "mobile"])
    .withMessage("keyType must be 'email' or 'mobile'"),
  body("keyValue").notEmpty().withMessage("keyValue is required"),
];

// Resend OTP
export const validateResendOtp = [
  ...headerValidation,
  body("keyType")
    .isIn(["email", "mobile"])
    .withMessage("keyType must be 'email' or 'mobile'"),
  body("keyValue").notEmpty().withMessage("keyValue is required"),
];

// Refresh Token
export const validateRefreshToken = [
  header("token").notEmpty().withMessage("Token header is required"),
];
