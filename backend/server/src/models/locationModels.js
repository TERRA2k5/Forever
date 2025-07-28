import pool from '../db.js';

export const addLocationService = async (latitude, longitude, id, fcm) => {
    const result = await pool.query(
        `INSERT INTO user_positions (latitude, longitude, id, fcm)
   VALUES ($1, $2, $3, $4)
   ON CONFLICT (id)
   DO UPDATE SET latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude`,
        [latitude, longitude, id, fcm]
    );
    return result.rowCount;
}

export const getUserPositionsService = async (id) => {
    const result = await pool.query(`
        SELECT * FROM user_positions WHERE id = $1;
        `, [id]);

    return result.rows[0];
};

export const debug_printAlll = async () => {
    const result = await pool.query(`
        SELECT * FROM user_positions;
        `);

    return result.rows;
};

export const dropUserPositionsTableService = async () => {
  const query = `
    DROP TABLE IF EXISTS user_positions;
  `;
  try {
    await pool.query(query);
    console.log("✅ 'user_positions' table deleted successfully.");
  } catch (err) {
    console.error("❌ Error dropping 'user_positions' table:", err);
  }
};