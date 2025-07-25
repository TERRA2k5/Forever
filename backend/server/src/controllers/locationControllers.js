import { addLocationService, getLocationService } from "../models/locationModels.js";

const handleRequest = (res, status, message, data = null) => {
    res.status(status).json({
        status,
        message,
        data,
    });
};

export const saveLocation = async (req, res, next) => {
    const { latitude, longitude, id, fcm } = req.body;
    try {
        const newLocation = await addLocationService(latitude, longitude, id, fcm);
        handleRequest(res, 201, "Location Updated", newLocation);
    }
    catch (e) {
        next(e);
    }
};

export const getLocation = async (req, res, next) => {
    const { id } = req.body;
    try {
        const loc = await getLocationService(id);
        handleRequest(res, 201, "Location fetched", loc);
    }
    catch (e) {
        next(e);
    }
};