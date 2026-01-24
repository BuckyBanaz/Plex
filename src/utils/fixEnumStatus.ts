import { Sequelize } from 'sequelize';
import logger from './logger';

export async function fixEnumStatus(sequelize: Sequelize) {
  logger.info('[DB FIX] Checking and repairing ENUMs if needed...');

  const enumsToFix = [
    {
      table: 'shipments',
      column: 'paymentStatus',
      enumName: 'enum_shipments_paymentStatus',
      values: ['PENDING', 'PAID', 'FAILED'],
      defaultValue: 'PENDING'
    }
  ];

  for (const { table, column, enumName, values, defaultValue } of enumsToFix) {
    try {
      // 1️⃣ Check if column exists
      const colCheck = await sequelize.query(`
        SELECT column_name FROM information_schema.columns
        WHERE table_name='${table}' AND column_name='${column}';
      `);
      if ((colCheck[0] as any[]).length === 0) {
        logger.warn(`[DB FIX] Column "${column}" not found in "${table}". Skipping.`);
        continue;
      }

      // 2️⃣ Drop default if exists
      logger.info(`[DB FIX] Dropping default for column "${column}" in "${table}"...`);
      await sequelize.query(`ALTER TABLE "${table}" ALTER COLUMN "${column}" DROP DEFAULT;`);

      // 3️⃣ Normalize data to uppercase to match ENUM values
      logger.info(`[DB FIX] Converting all existing "${column}" values to uppercase...`);
      await sequelize.query(`UPDATE "${table}" SET "${column}" = UPPER("${column}");`);

      // 4️⃣ Drop and recreate ENUM safely
      logger.info(`[DB FIX] Dropping and recreating type "${enumName}"...`);
      await sequelize.query(`
        DO $$ BEGIN
          IF EXISTS (SELECT 1 FROM pg_type WHERE typname = '${enumName}') THEN
            DROP TYPE "${enumName}" CASCADE;
          END IF;
        END $$;
      `);

      await sequelize.query(`CREATE TYPE "${enumName}" AS ENUM (${values.map(v => `'${v}'`).join(', ')});`);

      // 5️⃣ Alter column to new ENUM type
      logger.info(`[DB FIX] Altering column "${column}" to use new enum type "${enumName}"...`);
      await sequelize.query(`
        ALTER TABLE "${table}" 
        ALTER COLUMN "${column}" TYPE "${enumName}" USING UPPER("${column}")::"${enumName}";
      `);

      // 6️⃣ Restore default
      await sequelize.query(`
        ALTER TABLE "${table}" ALTER COLUMN "${column}" SET DEFAULT '${defaultValue}';
      `);

      logger.info(`[DB FIX] ✅ Enum "${enumName}" fixed successfully.`);
    } catch (err: any) {
      logger.error(`[DB FIX] ❌ Failed to fix ${enumName}: ${err.message}`);
    }
  }

  logger.info('[DB FIX] Enum repair process complete.');
}
