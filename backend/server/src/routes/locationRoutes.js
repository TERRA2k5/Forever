import express from 'express';
import { deleteUserPositionsTable, getAlluser_positons, getUserPositions, saveLocation , deleteID,updateName} from '../controllers/locationControllers.js';


const router = express.Router();

router.post("/location", saveLocation);
router.post("/userPositions", getUserPositions);
router.post("/updateName", updateName);
router.get("/userPositions", getAlluser_positons); //debug
router.delete("/userPositions", deleteUserPositionsTable); //debug
router.post("/locationDelete", deleteID); // debug

export default router;