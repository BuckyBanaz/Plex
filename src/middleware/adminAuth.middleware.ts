import jwt from "jsonwebtoken";
import fs from "fs";
import { Request, Response, NextFunction } from "express";

const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

export function adminAuthMiddleware(req: Request, res: Response, next: NextFunction) {
  try {
    const token = req.headers.token as string;

    if (!token) {
      return res.status(401).json({ success: false, message: "Admin token required" });
    }

    const decoded = jwt.verify(token, config.JWT_SECRET) as any;

    if (!decoded.adminId) {
      return res.status(403).json({ success: false, message: "Invalid admin access" });
    }

    (req as any).admin = decoded;
    next();
  } catch (err) {
    return res.status(401).json({ success: false, message: "Unauthorized admin" });
  }
}
