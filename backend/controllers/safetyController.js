import { PrismaClient } from '../generated/prisma/index.js';

const prisma = new PrismaClient();

// Get safety score for a location
export const getSafetyScore = async (req, res) => {
  try {
    const { userId, location, latitude, longitude } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required'
      });
    }

    // Check if we have existing safety score for this location
    let safetyScore;
    if (userId && location) {
      safetyScore = await prisma.safetyScore.findUnique({
        where: {
          userId_location: {
            userId,
            location
          }
        }
      });
    }

    // If no existing score, calculate a new one
    if (!safetyScore) {
      const calculatedScore = await calculateSafetyScore(
        parseFloat(latitude),
        parseFloat(longitude),
        location
      );

      if (userId && location) {
        // Save the calculated score
        safetyScore = await prisma.safetyScore.create({
          data: {
            userId,
            location,
            latitude: parseFloat(latitude),
            longitude: parseFloat(longitude),
            score: calculatedScore.score,
            factors: calculatedScore.factors
          }
        });
      } else {
        // Return calculated score without saving
        return res.json({
          success: true,
          data: calculatedScore
        });
      }
    }

    res.json({
      success: true,
      data: safetyScore
    });
  } catch (error) {
    console.error('Error fetching safety score:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch safety score',
      error: error.message
    });
  }
};

// Calculate safety score based on various factors
async function calculateSafetyScore(latitude, longitude, location) {
  try {
    // Mock safety calculation - in real implementation, this would use:
    // - Crime statistics from police data
    // - Historical incident reports
    // - Time of day
    // - Crowd density
    // - Police presence
    // - Tourist advisory data
    // - Weather conditions
    // - ML model predictions

    const factors = {
      crimeRate: Math.random() * 100, // 0-100 (lower is safer)
      policePresence: Math.random() * 100, // 0-100 (higher is safer)
      crowdDensity: Math.random() * 100, // 0-100 (moderate is safer)
      timeOfDay: getTimeOfDayScore(),
      weatherConditions: Math.random() * 100, // 0-100 (higher is safer)
      touristAdvisory: Math.random() * 100, // 0-100 (higher is safer)
      historicalIncidents: Math.random() * 100, // 0-100 (lower is safer)
      infrastructure: Math.random() * 100, // 0-100 (higher is safer)
      medicalFacilities: Math.random() * 100, // 0-100 (higher is safer)
      connectivity: Math.random() * 100 // 0-100 (higher is safer)
    };

    // Calculate weighted score
    const weights = {
      crimeRate: 0.25,
      policePresence: 0.15,
      crowdDensity: 0.10,
      timeOfDay: 0.10,
      weatherConditions: 0.05,
      touristAdvisory: 0.10,
      historicalIncidents: 0.15,
      infrastructure: 0.05,
      medicalFacilities: 0.05,
      connectivity: 0.05
    };

    let weightedScore = 0;
    
    // For factors where lower is better (crime, incidents)
    weightedScore += (100 - factors.crimeRate) * weights.crimeRate;
    weightedScore += (100 - factors.historicalIncidents) * weights.historicalIncidents;
    
    // For crowd density, moderate is best (bell curve)
    const crowdOptimal = Math.abs(factors.crowdDensity - 50);
    weightedScore += (100 - crowdOptimal * 2) * weights.crowdDensity;
    
    // For other factors, higher is better
    weightedScore += factors.policePresence * weights.policePresence;
    weightedScore += factors.timeOfDay * weights.timeOfDay;
    weightedScore += factors.weatherConditions * weights.weatherConditions;
    weightedScore += factors.touristAdvisory * weights.touristAdvisory;
    weightedScore += factors.infrastructure * weights.infrastructure;
    weightedScore += factors.medicalFacilities * weights.medicalFacilities;
    weightedScore += factors.connectivity * weights.connectivity;

    // Normalize to 0-10 scale
    const finalScore = Math.max(0, Math.min(10, weightedScore / 10));

    return {
      score: Math.round(finalScore * 100) / 100, // Round to 2 decimal places
      factors,
      calculation: {
        method: 'weighted_average',
        weights,
        timestamp: new Date().toISOString()
      }
    };
  } catch (error) {
    console.error('Error calculating safety score:', error);
    throw error;
  }
}

// Helper function to get time of day score
function getTimeOfDayScore() {
  const hour = new Date().getHours();
  
  // Safer during daytime (6 AM - 10 PM)
  if (hour >= 6 && hour <= 22) {
    return 80 + Math.random() * 20; // 80-100
  }
  // Less safe during night (10 PM - 6 AM)
  else {
    return 30 + Math.random() * 40; // 30-70
  }
}

// Update safety score
export const updateSafetyScore = async (req, res) => {
  try {
    const { id } = req.params;
    const updateData = req.body;

    const safetyScore = await prisma.safetyScore.update({
      where: { id },
      data: updateData
    });

    res.json({
      success: true,
      data: safetyScore,
      message: 'Safety score updated successfully'
    });
  } catch (error) {
    console.error('Error updating safety score:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Safety score not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to update safety score',
      error: error.message
    });
  }
};

// Get safety scores for a user
export const getUserSafetyScores = async (req, res) => {
  try {
    const { userId } = req.params;
    const { limit = 50 } = req.query;

    const safetyScores = await prisma.safetyScore.findMany({
      where: { userId },
      orderBy: { updatedAt: 'desc' },
      take: parseInt(limit),
      include: {
        user: {
          select: {
            id: true,
            name: true
          }
        }
      }
    });

    res.json({
      success: true,
      data: safetyScores
    });
  } catch (error) {
    console.error('Error fetching user safety scores:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch safety scores',
      error: error.message
    });
  }
};

// Delete safety score
export const deleteSafetyScore = async (req, res) => {
  try {
    const { id } = req.params;

    await prisma.safetyScore.delete({
      where: { id }
    });

    res.json({
      success: true,
      message: 'Safety score deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting safety score:', error);
    
    if (error.code === 'P2025') {
      return res.status(404).json({
        success: false,
        message: 'Safety score not found'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to delete safety score',
      error: error.message
    });
  }
};

// Get area safety overview
export const getAreaSafetyOverview = async (req, res) => {
  try {
    const { latitude, longitude, radius = 5 } = req.query;
    
    if (!latitude || !longitude) {
      return res.status(400).json({
        success: false,
        message: 'Latitude and longitude are required'
      });
    }

    // Get all safety scores in the area
    const safetyScores = await prisma.safetyScore.findMany({
      orderBy: { updatedAt: 'desc' }
    });

    // Filter by distance
    const lat1 = parseFloat(latitude);
    const lon1 = parseFloat(longitude);
    const radiusKm = parseFloat(radius);
    
    const filteredScores = safetyScores.filter(score => {
      const lat2 = score.latitude;
      const lon2 = score.longitude;
      
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

    // Calculate area statistics
    const scores = filteredScores.map(s => s.score);
    const avgScore = scores.length > 0 ? scores.reduce((a, b) => a + b, 0) / scores.length : 0;
    const minScore = scores.length > 0 ? Math.min(...scores) : 0;
    const maxScore = scores.length > 0 ? Math.max(...scores) : 0;

    res.json({
      success: true,
      data: {
        areaStatistics: {
          averageScore: Math.round(avgScore * 100) / 100,
          minimumScore: minScore,
          maximumScore: maxScore,
          totalLocations: filteredScores.length,
          searchRadius: radiusKm
        },
        locations: filteredScores
      }
    });
  } catch (error) {
    console.error('Error fetching area safety overview:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch area safety overview',
      error: error.message
    });
  }
};
