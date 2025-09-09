import { PrismaClient } from '../generated/prisma/index.js';

const prisma = new PrismaClient();

// Get all alerts for a user
export const getUserAlerts = async (req, res) => {
  try {
    const { userId } = req.params;
    const { resolved, severity, limit = 50 } = req.query;
    
    const where = { userId };
    
    if (resolved !== undefined) {
      where.isResolved = resolved === 'true';
    }
    
    if (severity) {
      where.severity = severity;
    }

    const alerts = await prisma.touristAlert.findMany({
      where,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true
          }
        },
        trip: {
          select: {
            id: true,
            status: true,
            tripStartDate: true,
            tripEndDate: true
          }
        }
      },
      orderBy: { createdAt: 'desc' },
      take: parseInt(limit)
    });

    res.json({
      success: true,
      data: alerts
    });
  } catch (error) {
    console.error('Error fetching alerts:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch alerts',
      error: error.message
    });
  }
};

// Get alert by ID
export const getAlertById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const alert = await prisma.touristAlert.findUnique({
      where: { id },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true,
            emergencyContactName: true,
            emergencyContactPhone: true
          }
        },
        trip: true
      }
    });

    if (!alert) {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    res.json({
      success: true,
      data: alert
    });
  } catch (error) {
    console.error('Error fetching alert:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch alert',
      error: error.message
    });
  }
};

// Create new alert
export const createAlert = async (req, res) => {
  try {
    const alertData = req.body;
    
    // Validate required fields
    if (!alertData.userId || !alertData.alertType || !alertData.message) {
      return res.status(400).json({
        success: false,
        message: 'User ID, alert type, and message are required'
      });
    }

    // Validate severity
    const validSeverities = ['low', 'medium', 'high', 'critical'];
    if (alertData.severity && !validSeverities.includes(alertData.severity)) {
      return res.status(400).json({
        success: false,
        message: `Invalid severity. Must be one of: ${validSeverities.join(', ')}`
      });
    }

    const alert = await prisma.touristAlert.create({
      data: alertData,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true
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
      data: alert,
      message: 'Alert created successfully'
    });
  } catch (error) {
    console.error('Error creating alert:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create alert',
      error: error.message
    });
  }
};

// Update alert
export const updateAlert = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const alert = await prisma.touristAlert.update({
      where: { id },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true
          }
        }
      }
    });

    res.json({
      success: true,
      data: alert,
      message: 'Alert updated successfully'
    });
  } catch (error) {
    console.error('Error updating alert:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update alert',
      error: error.message
    });
  }
};

// Resolve alert
export const resolveAlert = async (req, res) => {
  try {
    const { id } = req.params;

    const alert = await prisma.touristAlert.update({
      where: { id },
      data: { isResolved: true },
      include: {
        user: {
          select: {
            id: true,
            name: true,
            phoneNumber: true
          }
        }
      }
    });

    res.json({
      success: true,
      data: alert,
      message: 'Alert resolved successfully'
    });
  } catch (error) {
    console.error('Error resolving alert:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to resolve alert',
      error: error.message
    });
  }
};

// Delete alert
export const deleteAlert = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.touristAlert.delete({
      where: { id }
    });

    res.json({
      success: true,
      message: 'Alert deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting alert:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Alert not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to delete alert',
      error: error.message
    });
  }
};

// Get alerts by location
export const getAlertsByLocation = async (req, res) => {
  try {
    const { latitude, longitude, radius = 5 } = req.query; // radius in km
    
    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required'
      });
    }

    // Simple proximity search (in a real app, you'd use PostGIS or similar)
    const alerts = await prisma.touristAlert.findMany({
      where: {
        AND: [
          { latitude: { not: null } },
          { longitude: { not: null } },
          { isResolved: false }
        ]
      },
      include: {
        user: {
          select: {
            id: true,
            name: true
          }
        }
      },
      orderBy: { createdAt: 'desc' }
    });

    // Filter by distance (basic calculation)
    const lat1 = parseFloat(latitude);
    const lon1 = parseFloat(longitude);
    const radiusKm = parseFloat(radius);
    
    const filteredAlerts = alerts.filter(alert => {
      if (!alert.latitude || !alert.longitude) return false;
      
      const lat2 = alert.latitude;
      const lon2 = alert.longitude;
      
      // Calculate distance using Haversine formula
      const R = 6371; // Earth's radius in km
      const dLat = (lat2 - lat1) * Math.PI / 180;
      const dLon = (lon2 - lon1) * Math.PI / 180;
      const a = Math.sin(dLat/2) * Math.sin(dLat/2) +
                Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
                Math.sin(dLon/2) * Math.sin(dLon/2);
      const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
      const distance = R * c;
      
      return distance <= radiusKm;
    });

    res.json({
      success: true,
      data: filteredAlerts,
      meta: {
        searchRadius: radiusKm,
        totalFound: filteredAlerts.length
      }
    });
  } catch (error) {
    console.error('Error fetching alerts by location:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch alerts by location',
      error: error.message
    });
  }
};
