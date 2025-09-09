import express from "express";
import {
  getUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  uploadAadharCard,
  getKycStatus,
  registerUserOnBlockchain,
  getUserBlockchainData,
  getBlockchainStats,
} from "../controllers/userController.js";

const router = express.Router();

// User CRUD operations
router.get("/", getUsers);
router.get("/:id", getUserById);
router.post("/", createUser);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

// KYC operations
router.post("/:id/kyc/aadhar", uploadAadharCard);
router.get("/:id/kyc/status", getKycStatus);

// Blockchain operations
router.post("/:id/blockchain/register", registerUserOnBlockchain);
router.get("/:id/blockchain", getUserBlockchainData);
router.get("/blockchain/stats", getBlockchainStats);

export default router;
