import express from 'express';
import { deleteUserPositionsTable, getAlluser_positons, getUserPositions, saveLocation } from '../controllers/locationControllers.js';


const router = express.Router();

router.post("/location", saveLocation);
router.post("/userPositions", getUserPositions);
router.get("/userPositions", getAlluser_positons); //debug
router.delete("/userPositions", deleteUserPositionsTable); //debug

export default router;