import { Request, Response } from "express";
import * as adminService from "../services/adminAuth.service";

export async function createAdmin(req: Request, res: Response) {
  try {
    const { name, email, password, role } = req.body;

    const createdBy = (req as any).admin ?? null; // may be null for first admin

    const admin = await adminService.createAdmin(
      name,
      email,
      password,
      role,
      createdBy
    );

    return res.status(201).json({
      success: true,
      message: "Admin created successfully",
      admin,
    });
  } catch (error: any) {
    return res.status(400).json({ success: false, message: error.message });
  }
}

export async function adminLogin(req: Request, res: Response) {
  try {
    const { email, password } = req.body;

    const { admin, token } = await adminService.adminLogin(email, password);

    res.setHeader("token", token);

    return res.status(200).json({
      success: true,
      token,
      admin,
    });
  } catch (err: any) {
    return res.status(401).json({ success: false, message: err.message });
  }
}
