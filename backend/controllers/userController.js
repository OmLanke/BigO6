import { PrismaClient } from "../generated/prisma/index.js";
import blockchainService from "../services/blockchainService.js";

const prisma = new PrismaClient();

// Get all users
export const getUsers = async (req, res) => {
  try {
    const users = await prisma.user.findMany({
      include: {
        trips: true,
        alerts: {
          where: { isResolved: false },
          orderBy: { createdAt: "desc" },
        },
        _count: {
          select: {
            trips: true,
            alerts: true,
            locations: true,
          },
        },
      },
    });
    res.json({
      success: true,
      data: users,
    });
  } catch (error) {
    console.error("Error fetching users:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch users",
      error: error.message,
    });
  }
};

// Get user by ID
export const getUserById = async (req, res) => {
  try {
    const { id } = req.params;
    const user = await prisma.user.findUnique({
      where: { id },
      include: {
        trips: {
          orderBy: { createdAt: "desc" },
        },
        alerts: {
          orderBy: { createdAt: "desc" },
        },
        locations: {
          orderBy: { timestamp: "desc" },
          take: 10, // Last 10 locations
        },
        safetyScores: {
          orderBy: { createdAt: "desc" },
        },
      },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Get blockchain data if available
    const blockchainData = await blockchainService.getTouristBlockchainData(user.id);

    res.json({
      success: true,
      data: {
        ...user,
        blockchain: blockchainData
      },
    });
  } catch (error) {
    console.error("Error fetching user:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch user",
      error: error.message,
    });
  }
};

// Create new user
export const createUser = async (req, res) => {
  try {
    const userData = req.body;

    // Validate required fields
    if (!userData.email && !userData.phoneNumber) {
      return res.status(400).json({
        success: false,
        message: "Either email or phone number is required",
      });
    }

    const user = await prisma.user.create({
      data: userData,
    });

    // Try to register on blockchain (don't fail if blockchain is unavailable)
    let blockchainData = null;
    try {
      if (blockchainService.isBlockchainEnabled()) {
        const blockchainResult = await blockchainService.registerTourist(user.id);
        blockchainData = blockchainResult;
        
        // Update user with blockchain verification status
        if (blockchainResult.blockchainTouristId) {
          await prisma.user.update({
            where: { id: user.id },
            data: { isKycVerified: true }
          });
        }
      }
    } catch (blockchainError) {
      console.error('Blockchain registration failed:', blockchainError.message);
      // Continue without blockchain - don't fail user creation
    }

    res.status(201).json({
      success: true,
      data: user,
      blockchain: blockchainData,
      message: "User created successfully",
    });
  } catch (error) {
    console.error("Error creating user:", error);

    // Handle unique constraint violation
    if (error.code === "P2002") {
      return res.status(400).json({
        success: false,
        message: "User with this email already exists",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to create user",
      error: error.message,
    });
  }
};

// Update user
export const updateUser = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const user = await prisma.user.update({
      where: { id },
      data: updateData,
    });

    res.json({
      success: true,
      data: user,
      message: "User updated successfully",
    });
  } catch (error) {
    console.error("Error updating user:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to update user",
      error: error.message,
    });
  }
};

// Delete user
export const deleteUser = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.user.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: "User deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting user:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to delete user",
      error: error.message,
    });
  }
};

// Upload Aadhar card (Mock KYC)
export const uploadAadharCard = async (req, res) => {
  try {
    const { id } = req.params;

    // Mock file upload - in real implementation, you'd handle file upload here
    const mockAadharUrl = `https://kyc-storage.example.com/aadhar/${id}_${Date.now()}.jpg`;

    const user = await prisma.user.update({
      where: { id },
      data: {
        aadharCardUrl: mockAadharUrl,
        isKycVerified: true, // Auto-verify for mock implementation
      },
    });

    res.json({
      success: true,
      data: user,
      message: "Aadhar card uploaded and KYC verified successfully",
    });
  } catch (error) {
    console.error("Error uploading Aadhar card:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to upload Aadhar card",
      error: error.message,
    });
  }
};

// Get user's KYC status
export const getKycStatus = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.findUnique({
      where: { id },
      select: {
        id: true,
        name: true,
        isKycVerified: true,
        aadharCardUrl: true,
      },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    res.json({
      success: true,
      data: {
        isKycVerified: user.isKycVerified,
        hasAadharCard: !!user.aadharCardUrl,
        status: user.isKycVerified ? "verified" : "pending",
      },
    });
  } catch (error) {
    console.error("Error fetching KYC status:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch KYC status",
      error: error.message,
    });
  }
};

// Register user on blockchain
export const registerUserOnBlockchain = async (req, res) => {
  try {
    const { id } = req.params;

    // Get user from database
    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    // Register on blockchain
    const result = await blockchainService.registerTourist(user.id);

    // Update user with blockchain ID
    await prisma.user.update({
      where: { id },
      data: {
        blockchainId: result.touristId.toString(),
      },
    });

    res.json({
      success: true,
      message: "User registered on blockchain successfully",
      data: {
        touristId: result.touristId.toString(),
        transactionHash: result.transactionHash,
        blockNumber: result.blockNumber,
        gasUsed: result.gasUsed,
      },
    });
  } catch (error) {
    console.error("Error registering user on blockchain:", error);
    res.status(500).json({
      success: false,
      message: "Failed to register user on blockchain",
      error: error.message,
    });
  }
};

// Get user's blockchain data
export const getUserBlockchainData = async (req, res) => {
  try {
    const { id } = req.params;

    const user = await prisma.user.findUnique({
      where: { id },
    });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: "User not found",
      });
    }

    if (!user.blockchainId) {
      return res.status(404).json({
        success: false,
        message: "User not registered on blockchain",
      });
    }

    const blockchainData = await blockchainService.getTouristBlockchainData(
      user.blockchainId
    );

    res.json({
      success: true,
      data: blockchainData,
    });
  } catch (error) {
    console.error("Error fetching blockchain data:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch blockchain data",
      error: error.message,
    });
  }
};

// Get blockchain statistics
export const getBlockchainStats = async (req, res) => {
  try {
    const stats = await blockchainService.getBlockchainStats();

    res.json({
      success: true,
      data: stats,
    });
  } catch (error) {
    console.error("Error fetching blockchain stats:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch blockchain statistics",
      error: error.message,
    });
  }
};
