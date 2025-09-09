import { PrismaClient } from '../generated/prisma/index.js';

const prisma = new PrismaClient();

// Get all trips for a user
export const getUserTrips = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const trips = await prisma.trip.findMany({
      where: { userId },
      include: {
        alerts: {
          where: { isResolved: false }
        },
        locations: {
          orderBy: { timestamp: 'desc' },
          take: 1 // Latest location
        },
        _count: {
          select: {
            alerts: true,
            locations: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    res.json({
      success: true,
      data: trips
    });
  } catch (error) {
    console.error('Error fetching trips:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trips',
      error: error.message
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
            emergencyContactPhone: true
          }
        },
        alerts: {
          orderBy: { createdAt: 'desc' }
        },
        locations: {
          orderBy: { timestamp: 'desc' }
        }
      }
    });

    if (!trip) {
      return res.status(404).json({
        success: false,
        message: 'Trip not found'
      });
    }

    res.json({
      success: true,
      data: trip
    });
  } catch (error) {
    console.error('Error fetching trip:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trip',
      error: error.message
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
        message: 'User ID, start date, and end date are required'
      });
    }

    // Validate dates
    const startDate = new Date(tripData.tripStartDate);
    const endDate = new Date(tripData.tripEndDate);
    
    if (startDate >= endDate) {
      return res.status(400).json({
        success: false,
        message: 'End date must be after start date'
      });
    }

    const trip = await prisma.trip.create({
      data: {
        ...tripData,
        tripStartDate: startDate,
        tripEndDate: endDate
      },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            email: true
          }
        }
      }
    });

    res.status(201).json({
      success: true,
      data: trip,
      message: 'Trip created successfully'
    });
  } catch (error) {
    console.error('Error creating trip:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create trip',
      error: error.message
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
            email: true
          }
        }
      }
    });

    res.json({
      success: true,
      data: trip,
      message: 'Trip updated successfully'
    });
  } catch (error) {
    console.error('Error updating trip:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Trip not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update trip',
      error: error.message
    });
  }
};

// Delete trip
export const deleteTrip = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.trip.delete({
      where: { id }
    });

    res.json({
      success: true,
      message: 'Trip deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting trip:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Trip not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to delete trip',
      error: error.message
    });
  }
};

// Update trip status
export const updateTripStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { status } = req.body;

    const validStatuses = ['planned', 'active', 'completed', 'cancelled'];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({
        success: false,
        message: `Invalid status. Must be one of: ${validStatuses.join(', ')}`
      });
    }

    const trip = await prisma.trip.update({
      where: { id },
      data: { status }
    });

    res.json({
      success: true,
      data: trip,
      message: 'Trip status updated successfully'
    });
  } catch (error) {
    console.error('Error updating trip status:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Trip not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update trip status',
      error: error.message
    });
  }
};
