import express from "express";
import {
  getUserTrips,
  getTripById,
  createTrip,
  updateTrip,
  deleteTrip,
  updateTripStatus,
} from "../controllers/tripController.js";

const router = express.Router();

// Trip CRUD operations
router.get("/user/:userId", getUserTrips);
router.get("/:id", getTripById);
router.post("/", createTrip);
router.put("/:id", updateTrip);
router.delete("/:id", deleteTrip);

// Trip status management
router.patch("/:id/status", updateTripStatus);

export default router;
