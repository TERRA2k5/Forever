import express from 'express';
import { getAlluser_positons, getLocation, saveLocation } from '../controllers/locationControllers.js';


const router = express.Router();

router.post("/location", saveLocation);
router.post("/getLocation", getLocation);
router.get("/userPositions", getAlluser_positons);

export default router;