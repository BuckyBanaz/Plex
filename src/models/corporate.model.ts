import { Model, DataTypes, Optional, Sequelize } from 'sequelize';
import type User from './user.model';

interface CorporateAttributes {
  id: number;
  userId: number;
  companyName: string;
  sector?: string | null;
  commercialRegNo: string;
  taxRegNo?: string | null;
  websiteUrl?: string | null;
  country?: string | null;
  city?: string | null;
  district?: string | null;
  street?: string | null;
  buildingNo?: string | null;
  postalCode?: string | null;
  fullName?: string | null;
  position?: string | null;
  contactMobile?: string | null;
  contactEmail?: string | null;
  noOfEmployees?: number | null;
  expectedShipmentVolume?: number | null;
  advanceFees: number;
  deviceId: string
}

interface CorporateCreationAttributes
  extends Optional<
    CorporateAttributes,
    | 'id'
    | 'sector'
    | 'taxRegNo'
    | 'websiteUrl'
    | 'country'
    | 'city'
    | 'district'
    | 'street'
    | 'buildingNo'
    | 'postalCode'
    | 'position'
    | 'contactMobile'
    | 'contactEmail'
    | 'noOfEmployees'
    | 'expectedShipmentVolume'
    | 'advanceFees'
    | 'deviceId'
  > {}

export default class CorporateDetail
  extends Model<CorporateAttributes, CorporateCreationAttributes>
  implements CorporateAttributes
{
  public id!: number;
  public userId!: number;
  public companyName!: string;
  public sector!: string | null;
  public commercialRegNo!: string;
  public taxRegNo!: string | null;
  public websiteUrl!: string | null;
  public country!: string | null;
  public city!: string | null;
  public district!: string | null;
  public street!: string | null;
  public buildingNo!: string | null;
  public postalCode!: string | null;
  public fullName!: string;
  public position!: string | null;
  public contactMobile!: string | null;
  public contactEmail!: string | null;
  public noOfEmployees!: number | null;
  public expectedShipmentVolume!: number | null;
  public advanceFees!: number;
  public deviceId!: string;

  public user?: User;

  static initModel(sequelize: Sequelize) {
    CorporateDetail.init(
      {
        id: {
          type: DataTypes.INTEGER,
          primaryKey: true,
          autoIncrement: true,
        },
        userId: {
          type: DataTypes.INTEGER,
          allowNull: false,
        },
        companyName: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        sector: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        commercialRegNo: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        taxRegNo: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        websiteUrl: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        country: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        city: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        district: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        street: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        buildingNo: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        postalCode: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        fullName: {
          type: DataTypes.STRING,
          allowNull: false,
        },
        position: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        contactMobile: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        contactEmail: {
          type: DataTypes.STRING,
          allowNull: true,
        },
        noOfEmployees: {
          type: DataTypes.INTEGER,
          allowNull: true,
        },
        expectedShipmentVolume: {
          type: DataTypes.INTEGER,
          allowNull: true,
        },
        advanceFees: {
          type: DataTypes.DECIMAL(10, 2),
          allowNull: true,
          defaultValue: 0,
        },
        deviceId: {
          type : DataTypes.STRING,
          allowNull: true
        }
      },
      {
        tableName: 'corporate_details',
        sequelize,
        timestamps: true,
      }
    );
  }
}
