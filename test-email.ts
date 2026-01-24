import sgMail from "@sendgrid/mail";
import dotenv from "dotenv";
import fs from 'fs';
import path from 'path';

const configPath = path.join(__dirname, 'src', 'config', 'config.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

dotenv.config();

console.log("config=========> ", config);


sgMail.setApiKey(config.SENDGRID_API_KEY!);

async function testSend() {
  try {
    await sgMail.send({
      to: "akhilrec01@gmail.com",
      from: config.EMAIL_FROM!,
      subject: "Test Email",
      text: "This is a test",
      html: "<p>This is a test email</p>",
    });
    console.log("Email sent successfully");
  } catch (err: any) {
    console.error("SendGrid error:", err.response?.body || err.message);
  }
}

testSend();
