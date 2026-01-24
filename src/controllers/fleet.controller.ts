import { Request, Response } from 'express';
import { FleetService } from '../services/fleet.service';

const fleetService = new FleetService();

export class FleetController {
  async registerVehicle(req: Request, res: Response) {
    try {
      const vehicle = await fleetService.registerVehicle(req.body);
      res.status(201).json({ success: true, vehicle });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async getAllVehicles(req: Request, res: Response) {
    try {
      const vehicles = await fleetService.getAllVehicles();
      res.status(200).json({ success: true, vehicles });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async getVehicleById(req: Request, res: Response) {
    try {
      const vehicle = await fleetService.getVehicleById(Number(req.params.id));
      if (!vehicle) return res.status(404).json({ success: false, message: 'Vehicle not found' });
      res.status(200).json({ success: true, vehicle });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async updateVehicle(req: Request, res: Response) {
    try {
      const updatedVehicle = await fleetService.updateVehicle(Number(req.params.id), req.body);
      res.status(200).json({ success: true, vehicle: updatedVehicle });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async deleteVehicle(req: Request, res: Response) {
    try {
      await fleetService.deleteVehicle(Number(req.params.id));
      res.status(200).json({ success: true, message: 'Vehicle deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}
