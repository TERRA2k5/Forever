import express from 'express';
import { getLocation, saveLocation } from '../controllers/locationControllers.js';


const router = express.Router();

router.post("/location", saveLocation);
router.post("/getLocation", getLocation);


export default router;