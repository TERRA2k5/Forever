import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import pool from './db.js';
import locationRoutes from './routes/locationRoutes.js';
import createUserTable from './createTable.js';

dotenv.config(); // Load .env before anything else

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(express.json());
app.use(cors());

// PostgreSQL connection log
pool.on("connect", () => {
    console.log("✅ Connected to PostgreSQL");
});

// Create table (once at startup)
await createUserTable(); // Make sure to use await here if createUserTable is async

// Routes
app.use(locationRoutes);

// Health check / DB test route
app.get("/", async (req, res) => {
    try {
        const result = await pool.query("SELECT current_database()");
        res.send(`Database name is ${result.rows[0].current_database}`);
    } catch (err) {
        res.status(500).send("❌ Failed to connect to database");
    }
});

// Start server
app.listen(PORT, () => {
    console.log(`🚀 Server is running on port ${PORT}`);
});
