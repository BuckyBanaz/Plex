import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

export const permit = (allowedUserTypes: string[]) => {
  return (req: Request, res: Response, next: NextFunction) => {
    const user = req.user;

    if (!user) {
      logger.warn('Access denied: No user found in request.');
      return res.status(403).json({ message: 'Forbidden: no user found' });
    }

    if (!user.userType || !allowedUserTypes.includes(user.userType)) {
      logger.warn(`Access denied for user ID ${user.id || 'unknown'} with userType "${user.userType}". Required: ${allowedUserTypes.join(', ')}`);
      return res.status(403).json({ message: 'Forbidden: insufficient permissions' });
    }

    logger.info(`Access granted to user ID ${user.id || 'unknown'} with userType "${user.userType}".`);
    next();
  };
};
