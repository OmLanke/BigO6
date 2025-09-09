import express from "express";
import { 
  registerUser, 
  createTrip, 
  getUserProfile, 
  getUserTrips, 
  verifyTrip 
} from "../controllers/blockchainController.js";

const router = express.Router();

/**
 * @route   POST /api/blockchain/users
 * @desc    Register a new user with blockchain integration
 * @access  Public
 * @body    {
 *            name: string,
 *            email?: string,
 *            phoneNumber: string,
 *            ...otherUserData
 *          }
 */
router.post("/users", registerUser);

/**
 * @route   POST /api/blockchain/trips
 * @desc    Create a new trip with blockchain registration
 * @access  Public
 * @body    {
 *            userId: string,
 *            startDate: string (ISO date),
 *            endDate: string (ISO date),
 *            itinerary: string|object,
 *            ...otherTripData
 *          }
 */
router.post("/trips", createTrip);

/**
 * @route   GET /api/blockchain/users/:userId
 * @desc    Get user profile with blockchain data
 * @access  Public
 * @params  userId: string
 */
router.get("/users/:userId", getUserProfile);

/**
 * @route   GET /api/blockchain/users/:userId/trips
 * @desc    Get user's trips with blockchain verification
 * @access  Public
 * @params  userId: string
 */
router.get("/users/:userId/trips", getUserTrips);

/**
 * @route   GET /api/blockchain/trips/:tripId/verify
 * @desc    Verify trip on blockchain
 * @access  Public
 * @params  tripId: string
 */
router.get("/trips/:tripId/verify", verifyTrip);

export default router;
