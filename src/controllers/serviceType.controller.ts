import { Request, Response } from 'express';
import ServiceTypeService from '../services/serviceType.service';

export default class ServiceTypeController {
  static async create(req: Request, res: Response) {
    try {
      const data = req.body;
      const serviceType = await ServiceTypeService.create(data);
      res.status(201).json(serviceType);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  static async getAll(req: Request, res: Response) {
    try {
      const serviceTypes = await ServiceTypeService.getAll();
      res.json(serviceTypes);
    } catch (err: any) {
      res.status(500).json({ error: err.message });
    }
  }

  static async getById(req: Request, res: Response) {
    try {
      const id = parseInt(req.params.id);
      const serviceType = await ServiceTypeService.getById(id);
      if (!serviceType) return res.status(404).json({ error: 'ServiceType not found' });
      res.json(serviceType);
    } catch (err: any) {
      res.status(500).json({ error: err.message });
    }
  }

  static async update(req: Request, res: Response) {
    try {
      const id = parseInt(req.params.id);
      const data = req.body;
      const updated = await ServiceTypeService.update(id, data);
      res.json(updated);
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }

  static async delete(req: Request, res: Response) {
    try {
      const id = parseInt(req.params.id);
      await ServiceTypeService.delete(id);
      res.json({ message: 'ServiceType deleted successfully' });
    } catch (err: any) {
      res.status(400).json({ error: err.message });
    }
  }
}
