import express from "express";
import {
  getUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
  uploadAadharCard,
  getKycStatus,
  sendEmailOTP,
  verifyEmailOTP,
  completeUserRegistration,
  getUserProfileCompleteness,
  validateUserData,
} from "../controllers/userController.js";

const router = express.Router();

// Unified email OTP flow (supports both login and registration)
router.post("/auth/send-otp", sendEmailOTP);
router.post("/auth/verify-otp", verifyEmailOTP);
router.post("/:id/complete-registration", completeUserRegistration);

// User CRUD operations
router.get("/", getUsers);
router.get("/:id", getUserById);
router.post("/", createUser);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

// KYC operations
router.post("/:id/kyc/aadhar", uploadAadharCard);
router.get("/:id/kyc/status", getKycStatus);

// Profile management
router.get("/:id/profile/completeness", getUserProfileCompleteness);
router.post("/validate", validateUserData);

export default router;
