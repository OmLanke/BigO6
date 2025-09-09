import { PrismaClient } from "../generated/prisma/index.js";
import { generateOTP, storeOTP, verifyOTP, sendOTPEmail } from "../utils/emailService.js";

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

    res.json({
      success: true,
      data: user,
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

    res.status(201).json({
      success: true,
      data: user,
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

// Send OTP for email verification
export const sendEmailOTP = async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({
        success: false,
        message: "Email is required"
      });
    }

    // Check if email is valid
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({
        success: false,
        message: "Invalid email format"
      });
    }

    // Check if user already exists with this email
    const existingUser = await prisma.user.findUnique({
      where: { email }
    });

    if (existingUser) {
      return res.status(400).json({
        success: false,
        message: "User with this email already exists"
      });
    }

    // Generate and store OTP
    const otp = generateOTP();
    storeOTP(email, otp);

    // Send OTP via email
    await sendOTPEmail(email, otp);

    res.json({
      success: true,
      message: "OTP sent to email successfully"
    });
  } catch (error) {
    console.error("Error sending email OTP:", error);
    res.status(500).json({
      success: false,
      message: "Failed to send OTP",
      error: error.message
    });
  }
};

// Verify OTP and create initial user
export const verifyEmailOTP = async (req, res) => {
  try {
    const { email, otp } = req.body;

    if (!email || !otp) {
      return res.status(400).json({
        success: false,
        message: "Email and OTP are required"
      });
    }

    // Verify the OTP
    const verification = verifyOTP(email, otp);

    if (!verification.valid) {
      return res.status(400).json({
        success: false,
        message: verification.message
      });
    }

    // Create a minimal user with just the email
    const user = await prisma.user.create({
      data: { email }
    });

    res.status(201).json({
      success: true,
      message: "Email verified successfully",
      data: { userId: user.id, email: user.email }
    });
  } catch (error) {
    console.error("Error verifying email OTP:", error);

    // Handle unique constraint violation
    if (error.code === "P2002") {
      return res.status(400).json({
        success: false,
        message: "User with this email already exists"
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to verify email",
      error: error.message
    });
  }
};

// Complete user registration
export const completeUserRegistration = async (req, res) => {
  try {
    const { id } = req.params;
    const userData = req.body;

    // Remove email from userData as we don't want to update the email
    const { email, ...updateData } = userData;

    // Update the user with the additional information
    const user = await prisma.user.update({
      where: { id },
      data: updateData
    });

    res.json({
      success: true,
      message: "User registration completed successfully",
      data: user
    });
  } catch (error) {
    console.error("Error completing user registration:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "User not found"
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to complete registration",
      error: error.message
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
