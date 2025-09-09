import { PrismaClient } from "../generated/prisma/index.js";
import blockchainService from "../services/blockchainService.js";

const prisma = new PrismaClient();

// Get all trips for a user
export const getUserTrips = async (req, res) => {
  try {
    const { userId } = req.params;

    const trips = await prisma.trip.findMany({
      where: { userId },
      include: {
        alerts: {
          where: { isResolved: false },
        },
        locations: {
          orderBy: { timestamp: "desc" },
          take: 1, // Latest location
        },
        _count: {
          select: {
            alerts: true,
            locations: true,
          },
        },
      },
      orderBy: { createdAt: "desc" },
    });

    // Get blockchain verification data
    const blockchainData = await blockchainService.getTouristBlockchainData(userId);

    res.json({
      success: true,
      data: trips,
      blockchain: blockchainData,
    });
  } catch (error) {
    console.error("Error fetching trips:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch trips",
      error: error.message,
    });
  }
};

// Get trip by ID
export const getTripById = async (req, res) => {
  try {
    const { id } = req.params;

    const trip = await prisma.trip.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
            phoneNumber: true,
            emergencyContactName: true,
            emergencyContactPhone: true,
          },
        },
        alerts: {
          orderBy: { createdAt: "desc" },
        },
        locations: {
          orderBy: { timestamp: "desc" },
        },
      },
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    res.json({
      success: true,
      data: trip,
    });
  } catch (error) {
    console.error("Error fetching trip:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch trip",
      error: error.message,
    });
  }
};

// Create new trip
export const createTrip = async (req, res) => {
  try {
    const tripData = req.body;

    // Validate required fields
    if (!tripData.userId || !tripData.tripStartDate || !tripData.tripEndDate) {
      return res.status(400).json({
        success: false,
        message: "User ID, start date, and end date are required",
      });
    }

    // Validate dates
    const startDate = new Date(tripData.tripStartDate);
    const endDate = new Date(tripData.tripEndDate);

    if (startDate >= endDate) {
      return res.status(400).json({
        success: false,
        message: "End date must be after start date",
      });
    }

    const trip = await prisma.trip.create({
      data: {
        ...tripData,
        tripStartDate: startDate,
        tripEndDate: endDate,
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    // Try to register trip on blockchain
    let blockchainData = null;
    try {
      if (blockchainService.isBlockchainEnabled()) {
        // Create itinerary object with trip details
        const itinerary = {
          destination: tripData.destination,
          currentLocation: tripData.currentLocation,
          status: tripData.status || 'planned',
          createdAt: trip.createdAt,
          itinerary: tripData.itinerary || []
        };

        const blockchainResult = await blockchainService.registerTrip(
          trip.userId,
          trip.tripStartDate,
          trip.tripEndDate,
          itinerary
        );
        blockchainData = blockchainResult;
      }
    } catch (blockchainError) {
      console.error('Blockchain trip registration failed:', blockchainError.message);
      // Continue without blockchain - don't fail trip creation
    }

    res.status(201).json({
      success: true,
      data: trip,
      blockchain: blockchainData,
      message: "Trip created successfully",
    });
  } catch (error) {
    console.error("Error creating trip:", error);
    res.status(500).json({
      success: false,
      message: "Failed to create trip",
      error: error.message,
    });
  }
};

// Update trip
export const updateTrip = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    // Handle date updates
    if (updateData.tripStartDate) {
      updateData.tripStartDate = new Date(updateData.tripStartDate);
    }
    if (updateData.tripEndDate) {
      updateData.tripEndDate = new Date(updateData.tripEndDate);
    }

    const trip = await prisma.trip.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true,
          },
        },
      },
    });

    res.json({
      success: true,
      data: trip,
      message: "Trip updated successfully",
    });
  } catch (error) {
    console.error("Error updating trip:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to update trip",
      error: error.message,
    });
  }
};

// Delete trip
export const deleteTrip = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.trip.delete({
      where: { id },
    });

    res.json({
      success: true,
      message: "Trip deleted successfully",
    });
  } catch (error) {
    console.error("Error deleting trip:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to delete trip",
      error: error.message,
    });
  }
};

// Update trip status
export const updateTripStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ["planned", "active", "completed", "cancelled"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(", ")}`,
      });
    }

    const trip = await prisma.trip.update({
      where: { id },
      data: { status },
    });

    res.json({
      success: true,
      data: trip,
      message: "Trip status updated successfully",
    });
  } catch (error) {
    console.error("Error updating trip status:", error);

    if (error.code === "P2025") {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    res.status(500).json({
      success: false,
      message: "Failed to update trip status",
      error: error.message,
    });
  }
};

// Register trip on blockchain
export const registerTripOnBlockchain = async (req, res) => {
  try {
    const { id } = req.params;

    const trip = await prisma.trip.findUnique({
      where: { id },
      include: {
        user: true,
      },
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    if (!trip.user.blockchainId) {
      return res.status(400).json({
        success: false,
        message: "User must be registered on blockchain first",
      });
    }

    // Create itinerary object
    const itinerary = {
      destination: trip.destination,
      currentLocation: trip.currentLocation,
      status: trip.status,
      createdAt: trip.createdAt,
      itinerary: trip.itinerary || []
    };

    const result = await blockchainService.registerTrip(
      trip.user.blockchainId,
      JSON.stringify(itinerary)
    );

    // Update trip with blockchain ID
    await prisma.trip.update({
      where: { id },
      data: {
        blockchainId: result.tripId.toString(),
      },
    });

    res.json({
      success: true,
      message: "Trip registered on blockchain successfully",
      data: {
        tripId: result.tripId.toString(),
        transactionHash: result.transactionHash,
      },
    });
  } catch (error) {
    console.error("Error registering trip on blockchain:", error);
    res.status(500).json({
      success: false,
      message: "Failed to register trip on blockchain",
      error: error.message,
    });
  }
};

// Verify trip on blockchain
export const verifyTripOnBlockchain = async (req, res) => {
  try {
    const { id } = req.params;

    const trip = await prisma.trip.findUnique({
      where: { id },
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    if (!trip.blockchainId) {
      return res.status(404).json({
        success: false,
        message: "Trip not registered on blockchain",
      });
    }

    const verificationResult = await blockchainService.verifyTrip(
      trip.blockchainId
    );

    res.json({
      success: true,
      data: verificationResult,
    });
  } catch (error) {
    console.error("Error verifying trip on blockchain:", error);
    res.status(500).json({
      success: false,
      message: "Failed to verify trip on blockchain",
      error: error.message,
    });
  }
};

// Get trip's blockchain data
export const getTripBlockchainData = async (req, res) => {
  try {
    const { id } = req.params;

    const trip = await prisma.trip.findUnique({
      where: { id },
      include: {
        user: true,
      },
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: "Trip not found",
      });
    }

    if (!trip.blockchainId) {
      return res.status(404).json({
        success: false,
        message: "Trip not registered on blockchain",
      });
    }

    const blockchainData = await blockchainService.getTripBlockchainData(
      trip.blockchainId
    );

    res.json({
      success: true,
      data: blockchainData,
    });
  } catch (error) {
    console.error("Error fetching trip blockchain data:", error);
    res.status(500).json({
      success: false,
      message: "Failed to fetch trip blockchain data",
      error: error.message,
    });
  }
};
