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
} from "../controllers/userController.js";

const router = express.Router();

// Email verification and user registration flow
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

export default router;
