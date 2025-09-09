import express from "express";
import {
  getSafetyScore,
  updateSafetyScore,
  getUserSafetyScores,
  deleteSafetyScore,
  getAreaSafetyOverview,
} from "../controllers/safetyController.js";

const router = express.Router();

// Safety score operations
router.get("/", getSafetyScore);
router.get("/user/:userId", getUserSafetyScores);
router.get("/area/overview", getAreaSafetyOverview);
router.put("/:id", updateSafetyScore);
router.delete("/:id", deleteSafetyScore);

export default router;
