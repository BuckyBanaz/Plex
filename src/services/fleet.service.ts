import Vehicle from '../models/vehicle.model';
import User from '../models/user.model';

export class FleetService {
  async registerVehicle(data: any) {
    return await Vehicle.create(data);
  }

  async getAllVehicles() {
    return await Vehicle.findAll({ include: [{ model: User, as: 'driver' }] });
  }

  async getVehicleById(id: number) {
    return await Vehicle.findByPk(id);
  }

  async updateVehicle(id: number, updates: any) {
    await Vehicle.update(updates, { where: { id } });
    return await this.getVehicleById(id);
  }

  async deleteVehicle(id: number) {
    return await Vehicle.destroy({ where: { id } });
  }
}
