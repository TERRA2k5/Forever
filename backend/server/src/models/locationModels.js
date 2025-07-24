import pool from '../db.js';

export const addLocationService = async (latitude, longitude, id) => {
    const result = await pool.query(
        `INSERT INTO user_positions (latitude, longitude,id)
   VALUES ($1, $2, $3)
   ON CONFLICT (id)
   DO UPDATE SET latitude = EXCLUDED.latitude, longitude = EXCLUDED.longitude`,
        [latitude, longitude, id]
    );
    return result.rowCount;
}

export const getLocationService = async (id) => {
    const result = await pool.query(`
        SELECT * FROM user_positions WHERE id = $1;
        `, [id]);

    return result.rows[0];
};