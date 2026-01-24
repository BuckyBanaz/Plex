import { Request, Response } from "express";
import { TripService } from "../services/trip.service";

const tripService = new TripService();

export class TripController {
  async createTrip(req: Request, res: Response) {
    try {
      const trip = await tripService.createTrip(req.body);
      res.status(201).json({ success: true, trip });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async getAllTrips(req: Request, res: Response) {
    try {
      const trips = await tripService.getTrips();
      res.status(200).json({ success: true, trips });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async getTripById(req: Request, res: Response) {
    try {
      const trip = await tripService.getTripById(Number(req.params.id));
      if (!trip)
        return res
          .status(404)
          .json({ success: false, message: "Trip not found" });
      res.status(200).json({ success: true, trip });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async updateTrip(req: Request, res: Response) {
    try {
      const updatedTrip = await tripService.updateTrip(
        Number(req.params.id),
        req.body
      );
      res.status(200).json({ success: true, trip: updatedTrip });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async deleteTrip(req: Request, res: Response) {
    try {
      await tripService.deleteTrip(Number(req.params.id));
      res
        .status(200)
        .json({ success: true, message: "Trip deleted successfully" });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}
