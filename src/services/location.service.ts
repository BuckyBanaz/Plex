import UserLocation from '../models/userLocation.model';
import UserLocationHistory from '../models/userLocationHistory.model';

export interface SaveLocationPayload {
  latitude: number;
  longitude: number;
  accuracy?: number;
  heading?: number;
  speed?: number;
  deviceId?: string;
  recordedAt?: Date | string;
  userType?: 'individual' | 'driver' | 'company' | 'guest';
}

class LocationService {
  /**
   * Save a location row (latest + history)
   */
  async saveLocation(userId: number, payload: SaveLocationPayload) {
    // console.log("kjnkjdnjkndjkndjknjkd", userId, payload)
    const recordedAt = payload.recordedAt ? new Date(payload.recordedAt) : new Date();
    // console.log("jndjinjidnjosdjsnd============> ");
    
    // Insert into latest location (upsert)
    const latest = await UserLocation.upsert({
      userId,
      latitude: payload.latitude,
      longitude: payload.longitude,
    });

    // console.log("latest =========> ", latest)

    // Insert into history
    const history = await UserLocationHistory.create({
      userId,
      latitude: payload.latitude,
      longitude: payload.longitude,
      recordedAt
    });

    // console.log("history =======> ", history);
    

    return { latest, history };
  }

  /**
   * Get latest location
   */
  async getLatestLocation(userId: number) {
    const row = await UserLocation.findOne({
      where: { userId },
      order: [['updatedAt', 'DESC']],
    });
    return row;
  }

  /**
   * Get location history
   */
  async getLocations(userId: number, options?: { limit?: number; offset?: number; from?: Date | string; to?: Date | string }) {
    const where: any = { userId };

    if (options?.from || options?.to) {
      where.recordedAt = {};
      if (options.from) where.recordedAt['$gte'] = new Date(options.from);
      if (options.to) where.recordedAt['$lte'] = new Date(options.to);
    }

    const rows = await UserLocationHistory.findAll({
      where,
      limit: options?.limit ?? 50,
      offset: options?.offset ?? 0,
      order: [['recordedAt', 'DESC']],
    });

    return rows;
  }
}

export default new LocationService();
