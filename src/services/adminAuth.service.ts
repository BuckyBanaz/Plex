import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import Admin from "../models/admin.model";
import fs from "fs";

const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

const JWT_SECRET = config.JWT_SECRET;

// ==============================
// Create Admin (only by Super Admin)
// ==============================
export async function createAdmin(name: string, email: string, password: string, role: string, createdBy?: any) {

  const totalAdmins = await Admin.count();

  // If first admin → allow without token
  if (totalAdmins === 0) {
    const hashed = await bcrypt.hash(password, 10);
    return await Admin.create({ name, email, password: hashed, role });
  }

  // After first admin → require super admin
  if (!createdBy || createdBy.role !== "super_admin") {
    throw new Error("Only super admin can create new admins");
  }

  const existing = await Admin.findOne({ where: { email } });
  if (existing) throw new Error("Admin already exists");

  const hashed = await bcrypt.hash(password, 10);

  return await Admin.create({
    name,
    email,
    password: hashed,
    role,
  });
}

// ==============================
// Admin Login
// ==============================
export async function adminLogin(email: string, password: string) {
  const admin = await Admin.findOne({ where: { email } });
  if (!admin) throw new Error("Invalid email or password");

  const match = await bcrypt.compare(password, admin.password);
  if (!match) throw new Error("Invalid email or password");

  const token = jwt.sign(
    { adminId: admin.id, role: admin.role },
    JWT_SECRET,
    { expiresIn: "7d" }
  );

  const adminPlain = admin.get({ plain: true });
  const { password: pw, ...adminWithoutPassword } = adminPlain;

  return { admin: adminWithoutPassword, token };
}

