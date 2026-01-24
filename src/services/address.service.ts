import UserAddress from '../models/userAddress.model';

export interface AddressPayload {
  address: string;
  addressAs: string; // Home / Work / Other
  landmark?: string;
  locality?: string;
  latitude: number;
  longitude: number;
  isDefault?: boolean;
}


class AddressService {
  async addAddress(userId: number, payload: AddressPayload) {
    // If user sets this as default, reset others
    if (payload.isDefault) {
      await UserAddress.update({ isDefault: false }, { where: { userId } });
    }

    const address = await UserAddress.create({
      ...payload,
      userId,
      isDefault: payload.isDefault || false,
    });

    return address;
  }

  

  async getUserAddresses(userId: number) {
    const addresses = await UserAddress.findAll({
      where: { userId },
      order: [['isDefault', 'DESC'], ['createdAt', 'DESC']],
    });
    return addresses;
  }

  async setDefaultAddress(userId: number, addressId: number) {
    await UserAddress.update({ isDefault: false }, { where: { userId } });
    const updated = await UserAddress.update({ isDefault: true }, { where: { id: addressId, userId } });
    return updated;
  }

  async deleteAddress(userId: number, addressId: number) {
    const deleted = await UserAddress.destroy({ where: { id: addressId, userId } });
    return deleted > 0;
  }
}

export default new AddressService();
