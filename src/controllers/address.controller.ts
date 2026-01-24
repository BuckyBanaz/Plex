import { Request, Response } from 'express';
import AddressService from '../services/address.service';
import logger from '../utils/logger';

export async function addAddress(req: Request, res: Response) {
  try {
    
    const user = (req as any).user;
    
    if (!user) return res.status(401).json({ message: 'Unauthorized' });

    const { address, addressAs, landmark, locality, latitude, longitude, isDefault } = req.body;
    

    if (!address || !addressAs || latitude == null || longitude == null) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const created = await AddressService.addAddress(user.id, {
      address,
      addressAs,
      landmark,
      locality,
      latitude: Number(latitude),
      longitude: Number(longitude),
      isDefault,
    });
    

    res.status(201).json({ message: 'Address saved', data: created });
  } catch (err: any) {
    logger.error(`addAddress error: ${err.message}`);
    res.status(500).json({ message: 'Internal server error' });
  }
}

export async function getUserAddresses(req: Request, res: Response) {
  try {
    const user = (req as any).user;
    if (!user) return res.status(401).json({ message: 'Unauthorized' });

    const addresses = await AddressService.getUserAddresses(user.id);
    res.status(200).json({ data: addresses });
  } catch (err: any) {
    logger.error(`getUserAddresses error: ${err.message}`);
    res.status(500).json({ message: 'Internal server error' });
  }
}

export async function setDefaultAddress(req: Request, res: Response) {
  try {
    const user = (req as any).user;
    if (!user) return res.status(401).json({ message: 'Unauthorized' });

    const { addressId } = req.params;
    if (!addressId) return res.status(400).json({ message: 'Address ID required' });

    await AddressService.setDefaultAddress(user.id, Number(addressId));
    res.status(200).json({ message: 'Default address updated' });
  } catch (err: any) {
    logger.error(`setDefaultAddress error: ${err.message}`);
    res.status(500).json({ message: 'Internal server error' });
  }
}

export async function deleteAddress(req: Request, res: Response) {
  try {
    const user = (req as any).user;
    if (!user) return res.status(401).json({ message: 'Unauthorized' });

    const { addressId } = req.params;
    if (!addressId) return res.status(400).json({ message: 'Address ID required' });

    const deleted = await AddressService.deleteAddress(user.id, Number(addressId));
    if (!deleted) return res.status(404).json({ message: 'Address not found' });

    res.status(200).json({ message: 'Address deleted successfully' });
  } catch (err: any) {
    logger.error(`deleteAddress error: ${err.message}`);
    res.status(500).json({ message: 'Internal server error' });
  }
}
