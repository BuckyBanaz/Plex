import Trip from '../models/trip.model';

export class TripService {
  async createTrip(data: any) {
    return await Trip.create(data);
  }

  async getTrips() {
    return await Trip.findAll();
  }

  async getTripById(id: number) {
    return await Trip.findByPk(id);
  }

  async updateTrip(id: number, updates: any) {
    await Trip.update(updates, { where: { id } });
    return await this.getTripById(id);
  }

  async deleteTrip(id: number) {
    return await Trip.destroy({ where: { id } });
  }
}
