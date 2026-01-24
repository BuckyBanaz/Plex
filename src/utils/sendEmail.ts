import nodemailer from "nodemailer";
import fs from "fs";

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));

/**
 * Send OTP via SMTP (instead of SendGrid)
 * @param to - recipient email address
 * @param subject - email subject
 * @param otp - OTP to send
 */
export const sendOtpEmail = async (to: string, subject: string, otp: string) => {
  try {
    // Create reusable transporter object using SMTP
    const transporter = nodemailer.createTransport({
      host: config.SMTP_HOST, // e.g. smtp.gmail.com or your mail server
      port: Number(config.SMTP_PORT) || 587,
      secure: false, // true for port 465, false for 587
      auth: {
        user: config.SMTP_USER, // your SMTP username
        pass: config.SMTP_PASS, // your SMTP password
      },
    });

    // Email content
    const mailOptions = {
      from: `"PLEX APP" <${config.SMTP_USER}>`,
      to,
      subject,
      html: `
        <div style="font-family: Arial, sans-serif; padding: 20px;">
          <h2>PLEX OTP Verification</h2>
          <p>Your OTP code is:</p>
          <h1 style="color: #007BFF;">${otp}</h1>
          <p>This code will expire in 5 minutes. Do not share it with anyone.</p>
        </div>
      `,
    };

    // Send email
    const info = await transporter.sendMail(mailOptions);
    console.log(" OTP Email sent: %s", info.messageId);

    return true;
  } catch (error) {
    console.error(" Error sending OTP email:", error);
    return false;
  }
};

/**
 * Verifies SMTP connection on startup
 */
export const initSMTP = async () => {
  try {
    const transporter = nodemailer.createTransport({
      host: config.SMTP_HOST,
      port: Number(config.SMTP_PORT) || 587,
      secure: false,
      auth: {
        user: config.SMTP_USER,
        pass: config.SMTP_PASS,
      },
    });

    const verifyResult = await transporter.verify();
    console.log("[SMTP]  Verified connection:", verifyResult || "OK");
    
  } catch (err) {
    console.error("[SMTP]  Failed to verify SMTP connection:", err);
  }
};
