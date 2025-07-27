import express from 'express';
import { deleteUserPositionsTable, getAlluser_positons, getLocation, saveLocation } from '../controllers/locationControllers.js';


const router = express.Router();

router.post("/location", saveLocation);
router.post("/getLocation", getLocation);
router.get("/userPositions", getAlluser_positons);
router.delete("/userPositions", deleteUserPositionsTable);

export default router;