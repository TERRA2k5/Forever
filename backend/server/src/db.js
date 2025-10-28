import { Pool } from 'pg';
import dotenv from 'dotenv';

dotenv.config();

const pool = new Pool({
    connectionString: process.env.DATABASE_URL,
    ssl: {
        rejectUnauthorized: true,
    },
});

pool.on('connect', () => {
    console.log('Connection established with database');
});

export default pool;
