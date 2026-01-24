import { Request, Response } from 'express';
import { IntegrationService } from '../services/integration.service';

const integrationService = new IntegrationService();

export class IntegrationController {
  async saveToken(req: Request, res: Response) {
    try {
      const { provider, token, expiresAt } = req.body;
      const newToken = await integrationService.saveToken(provider, token, new Date(expiresAt));
      res.status(201).json({ success: true, token: newToken });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async getToken(req: Request, res: Response) {
    try {
      const { provider } = req.params;
      const token = await integrationService.getToken(provider);
      if (!token) return res.status(404).json({ success: false, message: 'Token not found' });
      res.status(200).json({ success: true, token });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }

  async deleteToken(req: Request, res: Response) {
    try {
      const { provider } = req.params;
      await integrationService.deleteToken(provider);
      res.status(200).json({ success: true, message: 'Token deleted successfully' });
    } catch (error: any) {
      res.status(500).json({ success: false, message: error.message });
    }
  }
}
