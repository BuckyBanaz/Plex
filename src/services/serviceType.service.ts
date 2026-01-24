import ServiceType from '../models/serviceType.model';

export default class ServiceTypeService {
  // Create a new ServiceType
  static async create(data: { name: string; description?: string }) {
    const serviceType = await ServiceType.create(data);
    return serviceType;
  }

  // Get all ServiceTypes
  static async getAll() {
    return await ServiceType.findAll();
  }

  // Get one ServiceType by ID
  static async getById(id: number) {
    return await ServiceType.findByPk(id);
  }

  // Update a ServiceType
  static async update(id: number, data: { name?: string; description?: string }) {
    const serviceType = await ServiceType.findByPk(id);
    if (!serviceType) throw new Error('ServiceType not found');
    return await serviceType.update(data);
  }

  // Delete a ServiceType
  static async delete(id: number) {
    const serviceType = await ServiceType.findByPk(id);
    if (!serviceType) throw new Error('ServiceType not found');
    await serviceType.destroy();
    return true;
  }
}
