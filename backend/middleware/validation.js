// Validation middleware for different entities

export const validateUser = (req, res, next) => {
  const { body } = req;
  const errors = [];

  // Validate email format if provided
  if (body.email && !/\S+@\S+\.\S+/.test(body.email)) {
    errors.push("Invalid email format");
  }

  // Validate phone number format if provided
  if (body.phoneNumber && !/^\+?[\d\s\-\(\)]+$/.test(body.phoneNumber)) {
    errors.push("Invalid phone number format");
  }

  // Validate required fields for registration
  if (req.method === "POST") {
    if (!body.email && !body.phoneNumber) {
      errors.push("Either email or phone number is required");
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors,
    });
  }

  next();
};

export const validateTrip = (req, res, next) => {
  const { body } = req;
  const errors = [];

  if (req.method === "POST") {
    // Required fields for trip creation
    if (!body.userId) errors.push("User ID is required");
    if (!body.tripStartDate) errors.push("Trip start date is required");
    if (!body.tripEndDate) errors.push("Trip end date is required");

    // Validate dates
    if (body.tripStartDate && body.tripEndDate) {
      const startDate = new Date(body.tripStartDate);
      const endDate = new Date(body.tripEndDate);

      if (isNaN(startDate.getTime())) errors.push("Invalid start date format");
      if (isNaN(endDate.getTime())) errors.push("Invalid end date format");

      if (startDate >= endDate) {
        errors.push("End date must be after start date");
      }
    }
  }

  // Validate status if provided
  if (body.status) {
    const validStatuses = ["planned", "active", "completed", "cancelled"];
    if (!validStatuses.includes(body.status)) {
      errors.push(
        `Invalid status. Must be one of: ${validStatuses.join(", ")}`
      );
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors,
    });
  }

  next();
};

export const validateAlert = (req, res, next) => {
  const { body } = req;
  const errors = [];

  if (req.method === "POST") {
    // Required fields for alert creation
    if (!body.userId) errors.push("User ID is required");
    if (!body.alertType) errors.push("Alert type is required");
    if (!body.message) errors.push("Message is required");
  }

  // Validate severity if provided
  if (body.severity) {
    const validSeverities = ["low", "medium", "high", "critical"];
    if (!validSeverities.includes(body.severity)) {
      errors.push(
        `Invalid severity. Must be one of: ${validSeverities.join(", ")}`
      );
    }
  }

  // Validate coordinates if provided
  if (body.latitude !== undefined) {
    const lat = parseFloat(body.latitude);
    if (isNaN(lat) || lat < -90 || lat > 90) {
      errors.push("Invalid latitude. Must be between -90 and 90");
    }
  }

  if (body.longitude !== undefined) {
    const lng = parseFloat(body.longitude);
    if (isNaN(lng) || lng < -180 || lng > 180) {
      errors.push("Invalid longitude. Must be between -180 and 180");
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors,
    });
  }

  next();
};

export const validateLocation = (req, res, next) => {
  const { body } = req;
  const errors = [];

  if (req.method === "POST") {
    // Required fields for location data
    if (!body.userId) errors.push("User ID is required");
    if (body.latitude === undefined) errors.push("Latitude is required");
    if (body.longitude === undefined) errors.push("Longitude is required");
  }

  // Validate coordinates
  if (body.latitude !== undefined) {
    const lat = parseFloat(body.latitude);
    if (isNaN(lat) || lat < -90 || lat > 90) {
      errors.push("Invalid latitude. Must be between -90 and 90");
    }
  }

  if (body.longitude !== undefined) {
    const lng = parseFloat(body.longitude);
    if (isNaN(lng) || lng < -180 || lng > 180) {
      errors.push("Invalid longitude. Must be between -180 and 180");
    }
  }

  // Validate accuracy if provided
  if (body.accuracy !== undefined) {
    const accuracy = parseFloat(body.accuracy);
    if (isNaN(accuracy) || accuracy < 0) {
      errors.push("Invalid accuracy. Must be a positive number");
    }
  }

  // Validate speed if provided
  if (body.speed !== undefined) {
    const speed = parseFloat(body.speed);
    if (isNaN(speed) || speed < 0) {
      errors.push("Invalid speed. Must be a positive number");
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors,
    });
  }

  next();
};

export const validateGeofence = (req, res, next) => {
  const { body } = req;
  const errors = [];

  if (req.method === "POST") {
    // Required fields for geofence creation
    if (!body.name) errors.push("Name is required");
    if (!body.coordinates) errors.push("Coordinates are required");
    if (!body.type) errors.push("Type is required");

    // Validate coordinates format
    if (body.coordinates) {
      if (!Array.isArray(body.coordinates)) {
        errors.push("Coordinates must be an array");
      } else if (body.coordinates.length < 3) {
        errors.push("Coordinates must have at least 3 points");
      } else {
        // Validate each coordinate pair
        body.coordinates.forEach((coord, index) => {
          if (!Array.isArray(coord) || coord.length !== 2) {
            errors.push(
              `Coordinate at index ${index} must be an array of [latitude, longitude]`
            );
          } else {
            const [lat, lng] = coord;
            if (typeof lat !== "number" || lat < -90 || lat > 90) {
              errors.push(
                `Invalid latitude at index ${index}. Must be between -90 and 90`
              );
            }
            if (typeof lng !== "number" || lng < -180 || lng > 180) {
              errors.push(
                `Invalid longitude at index ${index}. Must be between -180 and 180`
              );
            }
          }
        });
      }
    }

    // Validate type
    if (body.type) {
      const validTypes = [
        "safe_zone",
        "danger_zone",
        "restricted_area",
        "tourist_zone",
        "emergency_zone",
      ];
      if (!validTypes.includes(body.type)) {
        errors.push(`Invalid type. Must be one of: ${validTypes.join(", ")}`);
      }
    }
  }

  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      message: "Validation failed",
      errors,
    });
  }

  next();
};

// Generic UUID validation
export const validateUUID = (paramName) => {
  return (req, res, next) => {
    const id = req.params[paramName];
    const uuidRegex =
      /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

    if (!uuidRegex.test(id)) {
      return res.status(400).json({
        success: false,
        message: `Invalid ${paramName} format. Must be a valid UUID`,
      });
    }

    next();
  };
};
