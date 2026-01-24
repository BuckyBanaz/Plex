import { validationResult, ValidationError } from "express-validator";
import { Request, Response, NextFunction } from "express";

export function validateRequest(req: Request, res: Response, next: NextFunction) {
  const errors = validationResult(req);

  if (!errors.isEmpty()) {
    const formatted = errors.array().map((err: ValidationError) => ({
      field: "param" in err ? err.param : "unknown",
      message: err.msg || "Invalid input",
    }));

    return res.status(400).json({
      success: false,
      message: "Validation failed. Please check your input fields.",
      errors: formatted,
    });
  }

  next();
}
