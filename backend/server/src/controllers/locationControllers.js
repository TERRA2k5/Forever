import { addLocationService, debug_printAlll, dropUserPositionsTableService, getUserPositionsService } from "../models/locationModels.js";

const handleRequest = (res, status, message, data = null) => {
    res.status(status).json({
        status,
        message,
        data,
    });
};

export const saveLocation = async (req, res, next) => {
    const { latitude, longitude, id, fcm, email, name } = req.body;
    try {
        const newLocation = await addLocationService(latitude, longitude, id, fcm, email, name);
        handleRequest(res, 201, "Location Updated", newLocation);
    }
    catch (e) {
        next(e);
    }
};

export const getUserPositions = async (req, res, next) => {
    const { id } = req.body;
    try {
        const result = await getUserPositionsService(id);
        handleRequest(res, 200, "Location fetched", result);
    }
    catch (e) {
        next(e);
    }
};

export const getAlluser_positons = async (req, res, next) => {
    try {
        const result = await debug_printAlll();
        handleRequest(res, 200, "fetched all from user_positions", result);
    }
    catch (e) {
        next(e);
    }
};

export const deleteUserPositionsTable = async (req, res, next) => {
    try {
        await dropUserPositionsTableService();
        handleRequest(res, 200, "Table 'user_positions' deleted successfully.");
    }
    catch (e) {
        next(e);
    }
};
