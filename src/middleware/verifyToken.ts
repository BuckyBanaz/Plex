import jwt from 'jsonwebtoken';
import logger from '../utils/logger';
import fs from 'fs';

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));

export interface JwtPayload {
  id?: number;
  email?: string;
  userType?: string; // unified userType instead of role
  key?: string;
}

export function verifyToken(token: string): JwtPayload {
  try {
    const payload = jwt.verify(token, config.JWT_SECRET as string) as JwtPayload;
    logger.info(`Token verified successfully for payload: ${JSON.stringify(payload)}`);
    return payload;
  } catch (err: any) {
    logger.error(`Token verification failed: ${err.message}`, err);
    throw new Error('Invalid token');
  }
}
