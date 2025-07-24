import express, { json } from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import pool from './db.js'
import locationRoutes from './routes/locationRoutes.js';


const app = express();
dotenv.config();
const PORT = process.env.PORT || 5000;

// middlewares
app.use(express.json());
app.use(cors());

//routes
app.use(locationRoutes)

// testing  postgres connection
app.get("/", async (req, res) => {
    const result = await pool.query("SELECT current_database()");

    res.send(`database name is ${result.rows[0].current_database}`);
});

// server running
app.listen(PORT, () => (
    console.log(`server is working at port ${PORT}`)
));