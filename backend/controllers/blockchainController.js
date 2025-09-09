import { PrismaClient } from "../generated/prisma/index.js";
import { ethers } from "ethers";
import crypto from "crypto";
import { v4 as uuidv4 } from "uuid";

const prisma = new PrismaClient();

// Environment variables for blockchain interaction
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = process.env.RPC_URL;
const TOURIST_REGISTRY_ADDRESS = process.env.TOURIST_REGISTRY_ADDRESS;

// TouristRegistry contract ABI
const TOURIST_REGISTRY_ABI = [
  "function registerTourist(bytes32 _offChainIdHash) public returns (uint256)",
  "function registerTrip(uint256 _touristId, uint256 _startDate, uint256 _endDate, string memory _itinerary) public returns (uint256)",
  "function isTouristRegistered(uint256 _touristId) public view returns (bool)",
  "function getTourist(uint256 _touristId) public view returns (bytes32, bool)",
  "function getTrip(uint256 _tripId) public view returns (uint256, uint256, uint256, string)",
  "function getTouristIdByHash(bytes32 _offChainIdHash) public view returns (uint256)",
  "function getTouristTripIds(uint256 _touristId) public view returns (uint256[])",
  "function getTouristTripCount(uint256 _touristId) public view returns (uint256)",
  "function getMultipleTrips(uint256[] _tripIds) public view returns (uint256[], uint256[], uint256[], string[])",
  "function getTotalCounts() public view returns (uint256, uint256)"
];

// Initialize blockchain connection
const getBlockchainContract = () => {
  const provider = new ethers.JsonRpcProvider(RPC_URL);
  const wallet = new ethers.Wallet(PRIVATE_KEY, provider);
  return new ethers.Contract(TOURIST_REGISTRY_ADDRESS, TOURIST_REGISTRY_ABI, wallet);
};

/**
 * Register a new user (called from Flutter)
 * POST /api/users
 */
export const registerUser = async (req, res) => {
  try {
    const { name, email, phoneNumber, ...otherData } = req.body;

    if (!name || !phoneNumber) {
      return res.status(400).json({
        success: false,
        message: "Name and phone number are required"
      });
    }

    // Step 1: Store user in PostgreSQL and generate unique ID
    const userId = uuidv4();
    const user = await prisma.user.create({
      data: {
        id: userId,
        name,
        email: email || null,
        phoneNumber,
        ...otherData,
        isActive: true,
      }
    });

    // Step 2: Hash the user ID for blockchain storage
    const hashedUserId = ethers.keccak256(ethers.toUtf8Bytes(userId));

    // Step 3: Register on blockchain
    const contract = getBlockchainContract();
    const tx = await contract.registerTourist(hashedUserId);
    const receipt = await tx.wait();

    // Extract tourist ID from transaction logs
    const touristRegisteredEvent = receipt.logs.find(
      log => log.fragment && log.fragment.name === 'TouristRegistered'
    );
    
    const blockchainTouristId = touristRegisteredEvent ? 
      touristRegisteredEvent.args[0].toString() : null;

    // Step 4: Update user with blockchain tourist ID
    const updatedUser = await prisma.user.update({
      where: { id: userId },
      data: {
        // Add blockchainTouristId field to your schema if needed
        isKycVerified: true,
      }
    });

    res.status(201).json({
      success: true,
      message: "User registered successfully",
      data: {
        user: updatedUser,
        blockchainTouristId,
        transactionHash: receipt.hash
      }
    });

  } catch (error) {
    console.error("Error registering user:", error);
    res.status(500).json({
      success: false,
      message: "Failed to register user",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Create a new trip (called from Flutter)
 * POST /api/trips
 */
export const createTrip = async (req, res) => {
  try {
    const { userId, startDate, endDate, itinerary, ...tripData } = req.body;

    if (!userId || !startDate || !endDate || !itinerary) {
      return res.status(400).json({
        success: false,
        message: "userId, startDate, endDate, and itinerary are required"
      });
    }

    // Step 1: Get user from PostgreSQL
    const user = await prisma.user.findUnique({
      where: { id: userId }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    // Step 2: Get blockchain tourist ID
    const hashedUserId = ethers.keccak256(ethers.toUtf8Bytes(userId));
    const contract = getBlockchainContract();
    const blockchainTouristId = await contract.getTouristIdByHash(hashedUserId);

    if (blockchainTouristId.toString() === '0') {
      return res.status(400).json({
        success: false,
        message: "User not registered on blockchain"
      });
    }

    // Step 3: Create trip in PostgreSQL
    const trip = await prisma.trip.create({
      data: {
        userId,
        startDate: new Date(startDate),
        endDate: new Date(endDate),
        ...tripData,
        isActive: true,
      }
    });

    // Step 4: Register trip on blockchain
    const startTimestamp = Math.floor(new Date(startDate).getTime() / 1000);
    const endTimestamp = Math.floor(new Date(endDate).getTime() / 1000);
    const itineraryString = typeof itinerary === 'object' ? 
      JSON.stringify(itinerary) : itinerary.toString();

    const tx = await contract.registerTrip(
      blockchainTouristId,
      startTimestamp,
      endTimestamp,
      itineraryString
    );
    const receipt = await tx.wait();

    // Extract trip ID from transaction logs
    const tripRegisteredEvent = receipt.logs.find(
      log => log.fragment && log.fragment.name === 'TripRegistered'
    );
    
    const blockchainTripId = tripRegisteredEvent ? 
      tripRegisteredEvent.args[0].toString() : null;

    res.status(201).json({
      success: true,
      message: "Trip created successfully",
      data: {
        trip,
        blockchainTripId,
        transactionHash: receipt.hash
      }
    });

  } catch (error) {
    console.error("Error creating trip:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create trip",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Get user profile with blockchain data (called from Flutter)
 * GET /api/users/:userId
 */
export const getUserProfile = async (req, res) => {
  try {
    const { userId } = req.params;

    // Step 1: Get user from PostgreSQL
    const user = await prisma.user.findUnique({
      where: { id: userId },
      include: {
        trips: {
          orderBy: { createdAt: 'desc' }
        }
      }
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    // Step 2: Get blockchain data
    const hashedUserId = ethers.keccak256(ethers.toUtf8Bytes(userId));
    const contract = getBlockchainContract();
    
    const blockchainTouristId = await contract.getTouristIdByHash(hashedUserId);
    const isRegisteredOnChain = blockchainTouristId.toString() !== '0';
    
    let blockchainTrips = [];
    if (isRegisteredOnChain) {
      const tripIds = await contract.getTouristTripIds(blockchainTouristId);
      if (tripIds.length > 0) {
        const [touristIds, startDates, endDates, itineraries] = 
          await contract.getMultipleTrips(tripIds);
        
        blockchainTrips = tripIds.map((tripId, index) => ({
          blockchainTripId: tripId.toString(),
          touristId: touristIds[index].toString(),
          startDate: new Date(Number(startDates[index]) * 1000),
          endDate: new Date(Number(endDates[index]) * 1000),
          itinerary: itineraries[index]
        }));
      }
    }

    res.status(200).json({
      success: true,
      data: {
        user,
        blockchain: {
          touristId: blockchainTouristId.toString(),
          isRegistered: isRegisteredOnChain,
          tripCount: blockchainTrips.length,
          trips: blockchainTrips
        }
      }
    });

  } catch (error) {
    console.error("Error getting user profile:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get user profile",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Get user's trips with blockchain verification (called from Flutter)
 * GET /api/users/:userId/trips
 */
export const getUserTrips = async (req, res) => {
  try {
    const { userId } = req.params;

    // Get trips from PostgreSQL
    const trips = await prisma.trip.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' }
    });

    // Get blockchain verification
    const hashedUserId = ethers.keccak256(ethers.toUtf8Bytes(userId));
    const contract = getBlockchainContract();
    const blockchainTouristId = await contract.getTouristIdByHash(hashedUserId);
    
    let verifiedTrips = [];
    if (blockchainTouristId.toString() !== '0') {
      const blockchainTripIds = await contract.getTouristTripIds(blockchainTouristId);
      verifiedTrips = blockchainTripIds.map(id => id.toString());
    }

    res.status(200).json({
      success: true,
      data: {
        trips,
        blockchain: {
          touristId: blockchainTouristId.toString(),
          verifiedTripIds: verifiedTrips,
          verifiedCount: verifiedTrips.length
        }
      }
    });

  } catch (error) {
    console.error("Error getting user trips:", error);
    res.status(500).json({
      success: false,
      message: "Failed to get user trips",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

/**
 * Verify trip on blockchain (called from Flutter)
 * GET /api/trips/:tripId/verify
 */
export const verifyTrip = async (req, res) => {
  try {
    const { tripId } = req.params;

    // Get trip from PostgreSQL
    const trip = await prisma.trip.findUnique({
      where: { id: tripId },
      include: { user: true }
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found"
      });
    }

    // Check blockchain verification
    const hashedUserId = ethers.keccak256(ethers.toUtf8Bytes(trip.userId));
    const contract = getBlockchainContract();
    const blockchainTouristId = await contract.getTouristIdByHash(hashedUserId);
    
    if (blockchainTouristId.toString() === '0') {
      return res.status(400).json({
        success: false,
        message: "User not registered on blockchain"
      });
    }

    const blockchainTripIds = await contract.getTouristTripIds(blockchainTouristId);
    const isVerified = blockchainTripIds.length > 0;

    res.status(200).json({
      success: true,
      data: {
        trip,
        blockchain: {
          touristId: blockchainTouristId.toString(),
          isVerified,
          tripIds: blockchainTripIds.map(id => id.toString())
        }
      }
    });

  } catch (error) {
    console.error("Error verifying trip:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify trip",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};
