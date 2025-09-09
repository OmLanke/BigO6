import { PrismaClient } from '../generated/prisma/index.js';

const prisma = new PrismaClient();

// Record location data
export const recordLocation = async (req, res) => {
  try {
    const locationData = req.body;
    
    // Validate required fields
    if (!locationData.userId || !locationData.latitude || !locationData.longitude) {
      return res.status(400).json({
        success: false,
        message: 'User ID, latitude, and longitude are required'
      });
    }

    const location = await prisma.locationData.create({
      data: {
        ...locationData,
        timestamp: locationData.timestamp ? new Date(locationData.timestamp) : new Date()
      },
      include: {
        user: {
          select: {
            id: true,
            name: true
          }
        },
        trip: {
          select: {
            id: true,
            status: true
          }
        }
      }
    });

    res.status(201).json({
      success: true,
      data: location,
      message: 'Location recorded successfully'
    });
  } catch (error) {
    console.error('Error recording location:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to record location',
      error: error.message
    });
  }
};

// Get user's location history
export const getUserLocationHistory = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 100, tripId } = req.query;
    
    const where = { userId };
    if (tripId) {
      where.tripId = tripId;
    }

    const locations = await prisma.locationData.findMany({
      where,
      include: {
        trip: {
          select: {
            id: true,
            status: true,
            tripStartDate: true,
            tripEndDate: true
          }
        }
      },
      orderBy: { timestamp: 'desc' },
      take: parseInt(limit)
    });

    res.json({
      success: true,
      data: locations
    });
  } catch (error) {
    console.error('Error fetching location history:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch location history',
      error: error.message
    });
  }
};

// Get user's current location
export const getCurrentLocation = async (req, res) => {
  try {
    const { userId } = req.params;
    
    const location = await prisma.locationData.findFirst({
      where: { userId },
      orderBy: { timestamp: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            name: true
          }
        },
        trip: {
          select: {
            id: true,
            status: true
          }
        }
      }
    });

    if (!location) {
      return res.status(404).json({
        success: false,
        message: 'No location data found for user'
      });
    }

    res.json({
      success: true,
      data: location
    });
  } catch (error) {
    console.error('Error fetching current location:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch current location',
      error: error.message
    });
  }
};

// Get locations within a time range
export const getLocationsByTimeRange = async (req, res) => {
  try {
    const { userId } = req.params;
    const { startDate, endDate } = req.query;
    
    if (!startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Start date and end date are required'
      });
    }

    const locations = await prisma.locationData.findMany({
      where: {
        userId,
        timestamp: {
          gte: new Date(startDate),
          lte: new Date(endDate)
        }
      },
      orderBy: { timestamp: 'asc' }
    });

    res.json({
      success: true,
      data: locations,
      meta: {
        startDate,
        endDate,
        count: locations.length
      }
    });
  } catch (error) {
    console.error('Error fetching locations by time range:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch locations by time range',
      error: error.message
    });
  }
};
