import pool from './db.js';

const createUserTable = async () => {
    const query = `
    CREATE TABLE IF NOT EXISTS user_positions (
      id VARCHAR(100) NOT NULL,
      latitude FLOAT,
      longitude FLOAT
    );
  `;

    try {
        await pool.query(query);
        console.log("✅ 'user_positions' table created or already exists");
    } catch (err) {
        console.error("❌ Error creating 'users' table:", err);
    }
};

export default createUserTable;
