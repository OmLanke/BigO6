import { PrismaClient } from '../generated/prisma/index.js';

const prisma = new PrismaClient();

// Get all geofences
export const getGeofences = async (req, res) => {
  try {
    const { type, isActive } = req.query;
    
    const where = {};
    if (type) {
      where.type = type;
    }
    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    const geofences = await prisma.geofence.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });

    res.json({
      success: true,
      data: geofences
    });
  } catch (error) {
    console.error('Error fetching geofences:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch geofences',
      error: error.message
    });
  }
};

// Get geofence by ID
export const getGeofenceById = async (req, res) => {
  try {
    const { id } = req.params;
    
    const geofence = await prisma.geofence.findUnique({
      where: { id }
    });

    if (!geofence) {
      return res.status(404).json({
        success: false,
        message: 'Geofence not found'
      });
    }

    res.json({
      success: true,
      data: geofence
    });
  } catch (error) {
    console.error('Error fetching geofence:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch geofence',
      error: error.message
    });
  }
};

// Create new geofence
export const createGeofence = async (req, res) => {
  try {
    const geofenceData = req.body;
    
    // Validate required fields
    if (!geofenceData.name || !geofenceData.coordinates || !geofenceData.type) {
      return res.status(400).json({
        success: false,
        message: 'Name, coordinates, and type are required'
      });
    }

    // Validate coordinates format
    if (!Array.isArray(geofenceData.coordinates) || geofenceData.coordinates.length < 3) {
      return res.status(400).json({
        success: false,
        message: 'Coordinates must be an array with at least 3 points'
      });
    }

    // Validate geofence type
    const validTypes = ['safe_zone', 'danger_zone', 'restricted_area', 'tourist_zone', 'emergency_zone'];
    if (!validTypes.includes(geofenceData.type)) {
      return res.status(400).json({
        success: false,
        message: `Invalid type. Must be one of: ${validTypes.join(', ')}`
      });
    }

    const geofence = await prisma.geofence.create({
      data: geofenceData
    });

    res.status(201).json({
      success: true,
      data: geofence,
      message: 'Geofence created successfully'
    });
  } catch (error) {
    console.error('Error creating geofence:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create geofence',
      error: error.message
    });
  }
};

// Update geofence
export const updateGeofence = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const geofence = await prisma.geofence.update({
      where: { id },
      data: updateData
    });

    res.json({
      success: true,
      data: geofence,
      message: 'Geofence updated successfully'
    });
  } catch (error) {
    console.error('Error updating geofence:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Geofence not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update geofence',
      error: error.message
    });
  }
};

// Delete geofence
export const deleteGeofence = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.geofence.delete({
      where: { id }
    });

    res.json({
      success: true,
      message: 'Geofence deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting geofence:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Geofence not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to delete geofence',
      error: error.message
    });
  }
};

// Check if a point is within any geofences
export const checkPointInGeofences = async (req, res) => {
  try {
    const { latitude, longitude } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required'
      });
    }

    const lat = parseFloat(latitude);
    const lng = parseFloat(longitude);

    // Get all active geofences
    const geofences = await prisma.geofence.findMany({
      where: { isActive: true }
    });

    const intersectingGeofences = [];

    // Check each geofence
    for (const geofence of geofences) {
      if (isPointInPolygon([lat, lng], geofence.coordinates)) {
        intersectingGeofences.push(geofence);
      }
    }

    res.json({
      success: true,
      data: {
        point: { latitude: lat, longitude: lng },
        intersectingGeofences,
        totalIntersections: intersectingGeofences.length,
        hasIntersections: intersectingGeofences.length > 0
      }
    });
  } catch (error) {
    console.error('Error checking point in geofences:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to check point in geofences',
      error: error.message
    });
  }
};

// Get geofences by type
export const getGeofencesByType = async (req, res) => {
  try {
    const { type } = req.params;
    const { isActive } = req.query;
    
    const where = { type };
    if (isActive !== undefined) {
      where.isActive = isActive === 'true';
    }

    const geofences = await prisma.geofence.findMany({
      where,
      orderBy: { createdAt: 'desc' }
    });

    res.json({
      success: true,
      data: geofences,
      meta: {
        type,
        count: geofences.length
      }
    });
  } catch (error) {
    console.error('Error fetching geofences by type:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch geofences by type',
      error: error.message
    });
  }
};

// Get geofences within a bounding box
export const getGeofencesInArea = async (req, res) => {
  try {
    const { northLat, southLat, eastLng, westLng } = req.query;
    
    if (!northLat || !southLat || !eastLng || !westLng) {
      return res.status(400).json({
        success: false,
        message: 'Bounding box coordinates (northLat, southLat, eastLng, westLng) are required'
      });
    }

    // Get all geofences (in a real app, you'd use spatial indexing)
    const geofences = await prisma.geofence.findMany({
      where: { isActive: true }
    });

    // Filter geofences that intersect with the bounding box
    const geofencesInArea = geofences.filter(geofence => {
      const coords = geofence.coordinates;
      
      // Check if any coordinate is within the bounding box
      for (const coord of coords) {
        const [lat, lng] = coord;
        if (lat >= parseFloat(southLat) && lat <= parseFloat(northLat) &&
            lng >= parseFloat(westLng) && lng <= parseFloat(eastLng)) {
          return true;
        }
      }
      return false;
    });

    res.json({
      success: true,
      data: geofencesInArea,
      meta: {
        boundingBox: {
          north: parseFloat(northLat),
          south: parseFloat(southLat),
          east: parseFloat(eastLng),
          west: parseFloat(westLng)
        },
        count: geofencesInArea.length
      }
    });
  } catch (error) {
    console.error('Error fetching geofences in area:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch geofences in area',
      error: error.message
    });
  }
};

// Helper function to check if a point is inside a polygon
function isPointInPolygon(point, polygon) {
  const [x, y] = point;
  let inside = false;

  for (let i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    const [xi, yi] = polygon[i];
    const [xj, yj] = polygon[j];

    if (((yi > y) !== (yj > y)) && (x < (xj - xi) * (y - yi) / (yj - yi) + xi)) {
      inside = !inside;
    }
  }

  return inside;
}

// Activate/Deactivate geofence
export const toggleGeofenceStatus = async (req, res) => {
  try {
    const { id } = req.params;
    const { isActive } = req.body;

    if (typeof isActive !== 'boolean') {
      return res.status(400).json({
        success: false,
        message: 'isActive must be a boolean value'
      });
    }

    const geofence = await prisma.geofence.update({
      where: { id },
      data: { isActive }
    });

    res.json({
      success: true,
      data: geofence,
      message: `Geofence ${isActive ? 'activated' : 'deactivated'} successfully`
    });
  } catch (error) {
    console.error('Error toggling geofence status:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Geofence not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to toggle geofence status',
      error: error.message
    });
  }
};
