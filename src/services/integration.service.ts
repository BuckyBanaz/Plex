import IntegrationToken from '../models/integrationToken.model';

export class IntegrationService {
  async saveToken(provider: string, token: string, expiresAt: Date) {
    return await IntegrationToken.create({ provider, token, expiresAt });
  }

  async getToken(provider: string) {
    return await IntegrationToken.findOne({ where: { provider } });
  }

  async deleteToken(provider: string) {
    return await IntegrationToken.destroy({ where: { provider } });
  }
}
