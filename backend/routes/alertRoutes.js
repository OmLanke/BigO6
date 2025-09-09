import express from "express";
import {
  getUserAlerts,
  getAlertById,
  createAlert,
  updateAlert,
  resolveAlert,
  deleteAlert,
  getAlertsByLocation,
} from "../controllers/alertController.js";

const router = express.Router();

// Alert CRUD operations
router.get("/user/:userId", getUserAlerts);
router.get("/location", getAlertsByLocation);
router.get("/:id", getAlertById);
router.post("/", createAlert);
router.put("/:id", updateAlert);
router.delete("/:id", deleteAlert);

// Alert status management
router.patch("/:id/resolve", resolveAlert);

export default router;
