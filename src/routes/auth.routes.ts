import { Request, Response, Router } from "express";
import {
  registerIndividual,
  registerCorporate,
  registerGuest,
  verifyOtp,
  registerDriver,
  login,
  sendOtpHandler,
  resendOtpHandler,
  refreshTokenHandler,
  forgotPasswordController,
  verifyResetTokenController,
  resetPasswordController,
  updateFcmToken,
  updateOnlineStatus
} from "../controllers/auth.controller";

import {
  validateIndividual,
  validateCorporate,
  validateGuest,
  validateDriver,
  validateVerifyOtp,
  validateLogin,
  validateSendOtp,
  validateResendOtp,
  validateRefreshToken
} from "../validators/auth.validator";

import { validateRequest } from "../middleware/validateRequest";
import { authMiddleware } from "../middleware/auth.middleware";

const router = Router();

/**
 * RESET PASSWORD HTML PAGE
 * When user clicks email link → this page opens
 * Example link sent to user email:
 * https://p2dev10.in/reset-password?token=XYZ
 */
router.get("/reset-password", (req: Request, res: Response) => {
  const token = req.query.token || "";
 
  res.set("Content-Type", "text/html; charset=utf-8");
 
  res.send(`
  <!DOCTYPE html>
  <html lang="en">
  <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <title>Reset Password</title>
      <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
      <style>
        :root {
            --primary-color: #FFA726;
            --primary-hover: #FFA726;
            --bg-color: #f3f4f6;
            --card-bg: #ffffff;
            --text-color: #1f2937;
            --text-muted: #6b7280;
            --border-color: #e5e7eb;
            --input-bg: #f9fafb;
            --shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06);
        }
 
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }
 
        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--bg-color);
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            padding: 20px;
            color: var(--text-color);
        }
 
        .container {
            background: var(--card-bg);
            width: 100%;
            max-width: 420px;
            padding: 40px;
            border-radius: 16px;
            box-shadow: var(--shadow);
            text-align: center;
        }
 
        .logo {
            font-size: 28px;
            font-weight: 800;
            color: var(--primary-color);
            margin-bottom: 24px;
            letter-spacing: -0.5px;
            display: inline-block;
        }
 
        h2 {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 8px;
            color: var(--text-color);
        }
 
        .subtitle {
            color: var(--text-muted);
            font-size: 14px;
            margin-bottom: 32px;
            line-height: 1.5;
        }
 
        .form-group {
            margin-bottom: 20px;
            text-align: left;
        }
 
        label {
            display: block;
            font-size: 14px;
            font-weight: 500;
            margin-bottom: 8px;
            color: var(--text-color);
        }
 
        input {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            font-size: 15px;
            background-color: var(--input-bg);
            transition: all 0.2s ease;
            outline: none;
        }
 
        input:focus {
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(255, 167, 38, 0.2);
            background-color: #fff;
        }
 
        button {
            width: 100%;
            padding: 14px;
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: background-color 0.2s ease;
            margin-top: 8px;
        }
 
        button:hover {
            opacity: 0.9;
        }
 
        #result {
            margin-top: 20px;
            font-size: 14px;
            min-height: 20px;
        }
 
        .success { color: #059669; }
        .error { color: #dc2626; }
 
        /* Modal Styles */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            background: rgba(0, 0, 0, 0.5);
            display: flex;
            justify-content: center;
            align-items: center;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
            z-index: 1000;
        }
 
        .modal-overlay.active {
            opacity: 1;
            visibility: visible;
        }
 
        .modal {
            background: white;
            padding: 32px;
            border-radius: 16px;
            width: 90%;
            max-width: 360px;
            text-align: center;
            transform: translateY(20px);
            transition: transform 0.3s ease;
            box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
        }
 
        .modal-overlay.active .modal {
            transform: translateY(0);
        }
 
        .modal-icon {
            width: 64px;
            height: 64px;
            background-color: #FFF3E0;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 20px;
        }
 
        .modal-icon svg {
            width: 32px;
            height: 32px;
            color: var(--primary-color);
        }
 
        .modal h3 {
            font-size: 20px;
            font-weight: 700;
            color: var(--text-color);
            margin-bottom: 8px;
        }
 
        .modal p {
            color: var(--text-muted);
            font-size: 14px;
            line-height: 1.5;
            margin-bottom: 24px;
        }
 
        .modal-btn {
            background-color: var(--primary-color);
            color: white;
            border: none;
            border-radius: 8px;
            padding: 12px 24px;
            font-size: 15px;
            font-weight: 600;
            cursor: pointer;
            width: 100%;
            transition: opacity 0.2s;
        }
 
        .modal-btn:hover {
            opacity: 0.9;
        }
 
        @media (max-width: 480px) {
            .container {
                padding: 30px 20px;
            }
        }
      </style>
  </head>
 
  <body>
      <div class="container">
          <div class="logo">Plex</div>
          <h2>Reset Password</h2>
          <p class="subtitle">Enter your new password below to reset your account access.</p>
 
          <form id="resetForm">
              <input type="hidden" id="token" value="${token}" />
             
              <div class="form-group">
                  <label for="password">New Password</label>
                  <input type="password" id="password" placeholder="Enter new password" required />
              </div>
 
              <div class="form-group">
                  <label for="confirmPassword">Confirm Password</label>
                  <input type="password" id="confirmPassword" placeholder="Confirm new password" required />
              </div>
 
              <button type="submit">Reset Password</button>
          </form>
 
          <p id="result"></p>
      </div>
 
      <!-- Success Modal -->
      <div class="modal-overlay" id="successModal">
          <div class="modal">
              <div class="modal-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
                  </svg>
              </div>
              <h3>Password Reset!</h3>
              <p>Your password has been successfully reset. You can now login with your new password.</p>
              <button class="modal-btn" onclick="closeModal()">Back to Login</button>
          </div>
      </div>
 
      <script>
        const form = document.getElementById("resetForm");
        const result = document.getElementById("result");
        const modal = document.getElementById("successModal");
 
        function showModal() {
            modal.classList.add('active');
        }
 
        function closeModal() {
            // Redirect logic or close window
             window.location.href = "android-app://com.example.plex_user/https/p2dev10.in/reset-password"; // Example redirect
        }
 
        form.addEventListener("submit", async (e) => {
          e.preventDefault();
 
          const token = document.getElementById("token").value;
          const password = document.getElementById("password").value;
          const confirmPassword = document.getElementById("confirmPassword").value;
 
          if(password !== confirmPassword) {
              result.className = "error";
              result.innerText = "Passwords do not match!";
              return;
          }
 
          result.innerText = "Processing...";
          result.className = "";
 
          try {
              const res = await fetch("http://localhost:3000/reset-password", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                  token,
                  newPassword: password,
                  confirmPassword
                }),
              });
 
              const data = await res.json();
             
              if (res.ok) {
                  result.innerText = "";
                  showModal();
                  form.reset();
              } else {
                  result.className = "error";
                  result.innerText = data.message || "Something went wrong!";
              }
          } catch (error) {
              result.className = "error";
              result.innerText = "Network error. Please try again.";
          }
        });
      </script>
  </body>
  </html>
  `);
});


/**
 * @swagger
 * tags:
 *   name: Authentication
 *   description: User registration and authentication APIs
 */

/**
 * @swagger
 * /individual:
 *   post:
 *     summary: Register an individual user (OTP-based)
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - mobile
 *               - password
 *               - deviceId
 *               - otpType
 *               - fcmToken
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               mobile:
 *                 type: string
 *               password:
 *                 type: string
 *               deviceId:
 *                 type: string
 *               otpType:
 *                 type: string
 *               fcmToken:
 *                 type: string
 *     responses:
 *       201:
 *         description: OTP sent successfully
 *       400:
 *         description: Error in registration
 */
router.post("/individual", validateIndividual, validateRequest, registerIndividual);

/**
 * @swagger
 * /corporate:
 *   post:
 *     summary: Register a corporate user (OTP-based)
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - mobile
 *               - password
 *               - companyName
 *               - sector
 *               - commercialRegNo
 *               - deviceId
 *               - otpType
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               mobile:
 *                 type: string
 *               password:
 *                 type: string
 *               companyName:
 *                 type: string
 *               sector:
 *                 type: string
 *               commercialRegNo:
 *                 type: string
 *               deviceId:
 *                 type: string
 *               otpType:
 *                 type: string
 *     responses:
 *       201:
 *         description: OTP sent successfully
 *       400:
 *         description: Error in registration
 */
router.post("/corporate", validateCorporate, validateRequest, registerCorporate);

/**
 * @swagger
 * /guest:
 *   post:
 *     summary: Register a guest user (OTP-based)
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - mobile
 *               - deviceId
 *               - otpType
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               mobile:
 *                 type: string
 *               deviceId:
 *                 type: string
 *               otpType:
 *                 type: string
 *     responses:
 *       201:
 *         description: OTP sent successfully
 *       400:
 *         description: Error in registration
 */
router.post("/guest", validateGuest, validateRequest, registerGuest);

/**
 * @swagger
 * /driver:
 *   post:
 *     summary: Register a driver user (OTP-based)
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - name
 *               - email
 *               - password
 *               - mobile
 *               - deviceId
 *               - otpType
 *               - fcmToken
 *             properties:
 *               name:
 *                 type: string
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *               mobile:
 *                 type: string
 *               deviceId:
 *                 type: string
 *               otpType:
 *                 type: string
 *               fcmToken:
 *                 type: string
 *     responses:
 *       201:
 *         description: OTP sent successfully
 *       400:
 *         description: Error in registration
 */
router.post("/driver", validateDriver, validateRequest, registerDriver);

/**
 * @swagger
 * /verify-otp:
 *   post:
 *     summary: Verify OTP and complete registration
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: token
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: api_key
 *          schema:
 *            type: string
 *            required: true
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - keyType
 *               - keyValue
 *               - otp
 *             properties:
 *               keyType:
 *                 type: string
 *                 description: "Type of key, e.g., email or mobile"
 *               keyValue:
 *                 type: string
 *                 description: "Email or mobile number to verify"
 *               otp:
 *                 type: string
 *                 description: "One-time password"
 *     responses:
 *       200:
 *         description: OTP verified, user created, JWT token returned in header
 *       400:
 *         description: Invalid or expired OTP
 */
router.post("/verify-otp", validateVerifyOtp, validateRequest, verifyOtp);

/**
 * @swagger
 * /login:
 *   post:
 *     summary: User login endpoint
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *               - password
 *             properties:
 *               email:
 *                 type: string
 *               password:
 *                 type: string
 *     responses:
 *       200:
 *         description: Login successful, JWT token returned in header
 *       401:
 *         description: Invalid credentials
 */
router.post("/login", validateLogin, validateRequest, login);

/**
 * @swagger
 * /sms/send-otp:
 *   post:
 *     summary: Send OTP via SMS
 *     tags: [Authentication]
 *     description: Generate and send a 6-digit OTP to a user's mobile number using Twilio.
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - phoneNumber
 *             properties:
 *               phoneNumber:
 *                 type: string
 *                 example: "+919876543210"
 *     responses:
 *       200:
 *         description: OTP sent successfully
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 success:
 *                   type: boolean
 *                   example: true
 *                 message:
 *                   type: string
 *                   example: "OTP sent successfully"
 *                 otp:
 *                   type: number
 *                   example: 123456
 *       400:
 *         description: Invalid request (missing phone number)
 *       500:
 *         description: Server error while sending OTP
 */

router.post("/send-otp", validateSendOtp, validateRequest, sendOtpHandler);

/**
 * @swagger
 * /resend-otp:
 *   post:
 *     summary: Resend OTP to user (email or mobile)
 *     tags: [Authentication]
 *     parameters:
 *        - in: header
 *          name: lang_id
 *          schema:
 *            type: string
 *            required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - keyType
 *               - keyValue
 *             properties:
 *               keyType:
 *                 type: string
 *                 description: "Type of key (email or mobile)"
 *               keyValue:
 *                 type: string
 *                 description: "Email or mobile number"
 *     responses:
 *       200:
 *         description: OTP resent successfully
 *       400:
 *         description: Error while resending OTP
 */
router.post("/resend-otp", validateResendOtp, validateRequest, resendOtpHandler);

/**
 * @swagger
 * /refresh-token:
 *   post:
 *     summary: Generate a new access token using refresh token
 *     tags: [Authentication]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         description: Refresh token
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Returns new access token
 *       401:
 *         description: Invalid or expired refresh token
 */
router.post("/refresh-token", validateRefreshToken, validateRequest, refreshTokenHandler);

/**
 * @swagger
 * tags:
 *   name: Password Reset
 *   description: Forgot and reset password functionality
 */

/**
 * @swagger
 * /forgot-password:
 *   post:
 *     summary: Send a password reset link to the user's registered email
 *     tags: [Password Reset]
 *     parameters:
 *       - in: header
 *         name: lang_id
 *         schema:
 *           type: string
 *         required: true
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - email
 *             properties:
 *               email:
 *                 type: string
 *                 example: "user@example.com"
 *     responses:
 *       200:
 *         description: Reset link sent successfully
 *       400:
 *         description: Invalid email or user not found
 */
router.post("/forgot-password", validateRequest, forgotPasswordController);

/**
 * @swagger
 * /verify-reset-token:
 *   get:
 *     summary: Verify the validity of the password reset token
 *     tags: [Password Reset]
 *     parameters:
 *       - in: query
 *         name: token
 *         schema:
 *           type: string
 *         required: true
 *         description: Reset token received in email link
 *     responses:
 *       200:
 *         description: Token is valid
 *       400:
 *         description: Invalid or expired token
 */
router.get("/verify-reset-token", verifyResetTokenController);

/**
 * @swagger
 * /reset-password:
 *   post:
 *     summary: Reset the user password using a valid reset token
 *     tags: [Password Reset]
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required:
 *               - token
 *               - newPassword
 *               - confirmPassword
 *             properties:
 *               token:
 *                 type: string
 *                 description: Token received in email
 *                 example: "3a9c52b098c94a21b6d903f5fa6213e7"
 *               newPassword:
 *                 type: string
 *                 example: "MyNewPassword@123"
 *               confirmPassword:
 *                 type: string
 *                 example: "MyNewPassword@123"
 *     responses:
 *       200:
 *         description: Password reset successful
 *       400:
 *         description: Invalid token or password mismatch
 */
router.post("/reset-password", validateRequest, resetPasswordController);

/**
 * @swagger
 * /update-fcm/{userId}:
 *   put:
 *     summary: Update FCM token for a user
 *     tags: [Authentication]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         description: token
 *         schema:
 *           type: string
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID of the user whose FCM token should be updated
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               fcmToken:
 *                 type: string
 *                 example: "new-fcm-token-123"
 *     responses:
 *       200:
 *         description: FCM token updated successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */
router.put("/update-fcm/:userId", authMiddleware(), updateFcmToken);


/**
 * @swagger
 * /update-online-status/{userId}:
 *   put:
 *     summary: Update user's online status (login/logout)
 *     tags: [Authentication]
 *     parameters:
 *       - in: header
 *         name: token
 *         required: true
 *         description: JWT token for authentication
 *         schema:
 *           type: string
 *       - in: path
 *         name: userId
 *         required: true
 *         schema:
 *           type: string
 *         description: ID of the user whose online status should be updated
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               isOnline:
 *                 type: boolean
 *                 example: true
 *     responses:
 *       200:
 *         description: Online status updated successfully
 *       400:
 *         description: Invalid input
 *       404:
 *         description: User not found
 *       500:
 *         description: Internal server error
 */
router.put(
  "/update-online-status/:userId",
  authMiddleware(), updateOnlineStatus
);


/**
 * @openapi
 * /hello:
 *   get:
 *     summary: Test route
 *     responses:
 *       200:
 *         description: Returns hello
 */
router.get("/hello", (req, res) => {
  res.send("Hello Swagger!");
});

export default router;
