import { Sequelize } from 'sequelize';
import dotenv from 'dotenv';
import { Client } from 'pg';
import logger from '../utils/logger'; 
import { initModels } from '../models'; 
import { fixEnumStatus } from '../utils/fixEnumStatus'
import fs from 'fs';

dotenv.config();

const config = JSON.parse(fs.readFileSync(__dirname + "/../config/config.json", "utf-8"));

const databaseUrl = config.DATABASE_URL as string;
if (!databaseUrl) {
  logger.error('DATABASE_URL is not defined in .env');
  throw new Error('DATABASE_URL is not defined in .env');
}

// Extract DB name from DATABASE_URL
function getDatabaseName(url: string): string {
  const match = url.match(/\/([^/?]+)(\?.*)?$/);
  if (!match) {
    logger.error('Could not parse database name from DATABASE_URL');
    throw new Error('Could not parse database name from DATABASE_URL');
  }
  return match[1];
}



// Ensure DB exists
async function ensureDatabaseExists() {
  const dbName = getDatabaseName(databaseUrl);
  const defaultDbUrl = databaseUrl.replace(`/${dbName}`, '/postgres');

  logger.info(`Checking if database "${dbName}" exists...`);

  const sysClient = new Client({ connectionString: defaultDbUrl });
  try {
    await sysClient.connect();
    logger.info(`Connected to system database: postgres`);

    const result = await sysClient.query(
      `SELECT 1 FROM pg_database WHERE datname=$1`,
      [dbName]
    );
    if (result.rowCount === 0) {
      logger.warn(`Database "${dbName}" does not exist. Creating...`);
      await sysClient.query(`CREATE DATABASE "${dbName}"`);
      logger.info(`Database "${dbName}" created successfully.`);
    } else {
      logger.info(`Database "${dbName}" already exists.`);
    }
  } catch (err: any) {
    logger.error(`Error while ensuring database "${dbName}" exists: ${err.message}`, err);
    throw err;
  } finally {
    await sysClient.end();
    logger.info('System database connection closed.');
  }
}

// Initialize Sequelize
export const sequelize = new Sequelize(databaseUrl, {
  dialect: 'postgres',
  logging: (msg) => logger.debug(msg),
  // dialectOptions: config.NODE_ENV.toLowerCase() === 'production' ? {
  //   ssl: {
  //     require: true,
  //     rejectUnauthorized: false, // for RDS / production
  //   },
  // } : undefined, // do NOT pass ssl object for local
});

// ----------------------
// Initialize database
// ----------------------
export async function initDatabase() {
  try {
    logger.info('Initializing database...');
    await ensureDatabaseExists();

    await sequelize.authenticate();
    logger.info('Database connection authenticated successfully.');

    // Run enum fixer before syncing models
    await fixEnumStatus(sequelize);

    // Initialize all models and associations
    initModels(sequelize);

    // Sync all models
    await sequelize.sync({ alter: true });
    logger.info('Database synced successfully (models aligned).');

    // Add 'driver' to enum_users_userType if missing
    await ensureDriverEnum();
  } catch (err: any) {
    logger.error(`Unable to initialize database: ${err.message}`, err);
    process.exit(1);
  }
}

// ----------------------
// Ensure 'driver' exists in enum_users_userType
// ----------------------
async function ensureDriverEnum() {
  try {
    const enumCheck = await sequelize.query(`
      SELECT 1
      FROM pg_type t
      JOIN pg_enum e ON t.oid = e.enumtypid
      WHERE t.typname = 'enum_users_userType' AND e.enumlabel = 'driver';
    `);

    if ((enumCheck[0] as any[]).length === 0) {
      logger.info(`Adding 'driver' to enum_users_userType...`);
      await sequelize.query(`ALTER TYPE "enum_users_userType" ADD VALUE IF NOT EXISTS 'driver';`);
      logger.info(`'driver' added to enum_users_userType successfully.`);
    } else {
      logger.info(`'driver' already exists in enum_users_userType.`);
    }
  } catch (err: any) {
    logger.warn(
      `Could not add 'driver' to enum_users_userType yet (might not exist). Will try after sync.`
    );
  }
}
