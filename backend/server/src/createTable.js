import pool from './db.js';

const createUserTable = async () => {
  const query = `
    CREATE TABLE IF NOT EXISTS user_positions (
      id VARCHAR(10) PRIMARY KEY,
      name VARCHAR(100),
      email VARCHAR(100),
      latitude FLOAT,
      longitude FLOAT,
      fcm TEXT
    );
  `;

  try {
    await pool.query(query);
    console.log("✅ 'user_positions' table created or already exists");
  } catch (err) {
    console.error("❌ Error creating 'user_positions' table:", err);
  }
};

export default createUserTable;
