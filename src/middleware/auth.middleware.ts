import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import logger from "../utils/logger";
import fs from "fs";

const config = JSON.parse(
  fs.readFileSync(__dirname + "/../config/config.json", "utf-8")
);

interface JwtPayloadCustom {
  id?: number;
  userId?: number; 
  email?: string;
  userType?: string;
  key?: string;
}

export const verifyToken = (token: string): JwtPayloadCustom => {
  try {
    const payload = jwt.verify(token, config.JWT_SECRET as string) as JwtPayloadCustom;
    logger.info(`Token verified successfully for payload: ${JSON.stringify(payload)}`);
    return payload;
  } catch (err: any) {
    logger.error(`Token verification failed: ${err.message}`, err);
    throw new Error("Invalid token");
  }
};

export const authMiddleware = (allowedUserTypes: string[] = []) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const token =
      req.headers.authorization?.split(" ")[1] ||
      (req.headers["token"] as string);

    if (!token) {
      logger.warn(`Unauthorized access attempt - Missing token | URL: ${req.originalUrl}`);
      return res.status(401).json({ message: "Missing or invalid token" });
    }

    try {
      const payload = verifyToken(token);

      //  Normalize ID for consistent access in all services
      (req as any).user = {
        ...payload,
        id: payload.userId || payload.id, // always ensure id is available
        userId: payload.userId || payload.id,
      };

      logger.info(
        `Token verified for user: ${payload?.email || payload?.userId || payload?.id || "Unknown"}`
      );

      if (
        allowedUserTypes.length &&
        (!payload.userType || !allowedUserTypes.includes(payload.userType))
      ) {
        logger.warn(
          `Access denied for user: ${payload?.email || payload?.userId || payload?.id || "Unknown"} | Required userType: ${allowedUserTypes.join(
            ", "
          )} | User userType: ${payload.userType || "none"}`
        );
        return res.status(403).json({ message: "Forbidden: insufficient permissions" });
      }

      next();
    } catch (err: any) {
      logger.error(
        `Invalid or expired token for request to ${req.originalUrl}: ${err.message}`,
        err
      );
      return res.status(401).json({ message: "Invalid token" });
    }
  };
};

export function adminMiddleware(req: Request, res: Response, next: NextFunction) {
  const user = (req as any).user;
  if (user.userType !== "admin") {
    return res.status(403).json({ message: "Access denied: Admins only" });
  }
  next();
}
