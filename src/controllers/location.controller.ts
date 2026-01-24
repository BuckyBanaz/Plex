// controllers/location.controller.ts
import { Request, Response } from "express";
import LocationService from "../services/location.service";
import logger from "../utils/logger";
import fs from "fs";

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));

// helper to parse numeric query params
const toNumber = (v: any, fallback = 0) => {
  const n = Number(v);
  return Number.isNaN(n) ? fallback : n;
};

// ==========================
// Save Location (POST /api/user/location)
// ==========================
export async function saveLocation(req: Request, res: Response) {
  try {
    const user = (req as any).user;
    // console.log("user =======> ", user);
    
    const lang_id = req.headers.lang_id;
        // console.log("lang_id =======> ", lang_id);
    const api_key = req.headers.api_key;
    // console.log("api_key ======> ", api_key);
    

    if (!lang_id || !api_key) {
      return res.status(400).json({ message: "city_id , lang_id & api_key are required" });
    }

    if (lang_id !== config.LANG_ID_ENG || api_key !== config.API_KEY) {
      return res.status(400).json({ message: "Invalid city_id , lang_id & api_key" });
    }

    if (!user) return res.status(401).json({ message: "Unauthorized" });

    const { latitude, longitude, accuracy, heading, speed, recorded_at } = req.body;
    if (latitude == null || longitude == null) {
      return res.status(400).json({ message: "latitude and longitude are required" });
    }
    // console.log("kndjknjkdnjkdnjdjd");
    
    //  Use user.id (as per Option 2)
    const created = await LocationService.saveLocation(user.id, {
      latitude: Number(latitude),
      longitude: Number(longitude),
      accuracy: accuracy ? Number(accuracy) : undefined,
      heading: heading ? Number(heading) : undefined,
      speed: speed ? Number(speed) : undefined,
      recordedAt: recorded_at,
      userType: user.userType,
    });

    // console.log("created ========> ", created);
    

    res.status(201).json({ message: "Location saved", data: created });
  } catch (err: any) {
    logger.error(`saveLocation error: ${err.message}`, err);
    res.status(500).json({ message: "Internal server error" });
  }
}

// ==========================
// Get Latest Location (GET /api/user/location/latest)
// ==========================
export async function getLatestLocation(req: Request, res: Response) {
  try {
    const userId = (req as any).user?.id;
    if (!userId) return res.status(401).json({ message: "Unauthorized" });

    const latest = await LocationService.getLatestLocation(userId);
    if (!latest) return res.status(404).json({ message: "No location found" });

    res.status(200).json({ data: latest });
  } catch (err: any) {
    logger.error(`getLatestLocation error: ${err.message}`, err);
    res.status(500).json({ message: "Internal server error" });
  }
}

// ==========================
// Get User Location History (GET /api/users/:userId/locations)
// ==========================
export async function getUserLocations(req: Request, res: Response) {
  try {
    const authUser = (req as any).user;
    if (!authUser) return res.status(401).json({ message: "Unauthorized" });

    const userId = Number(req.params.userId);
    if (Number.isNaN(userId)) return res.status(400).json({ message: "Invalid userId" });

    // Optional: Restrict access if needed
    // if (!authUser.isAdmin && authUser.id !== userId) return res.status(403).json({ message: "Forbidden" });

    const limit = toNumber(req.query.limit, 50);
    const offset = toNumber(req.query.offset, 0);
    const from = req.query.from as string | undefined;
    const to = req.query.to as string | undefined;

    const rows = await LocationService.getLocations(userId, { limit, offset, from, to });
    res.status(200).json({ data: rows });
  } catch (err: any) {
    logger.error(`getUserLocations error: ${err.message}`, err);
    res.status(500).json({ message: "Internal server error" });
  }
}
