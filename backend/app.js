import express from "express";
import cors from "cors";
import { PrismaClient } from "./generated/prisma/index.js";

// Import routes
import userRoutes from "./routes/userRoutes.js";
import tripRoutes from "./routes/tripRoutes.js";
import alertRoutes from "./routes/alertRoutes.js";
import locationRoutes from "./routes/locationRoutes.js";
import safetyRoutes from "./routes/safetyRoutes.js";
import geofenceRoutes from "./routes/geofenceRoutes.js";

// Import middleware
import {
  errorHandler,
  notFound,
  requestLogger,
  corsHeaders,
  rateLimit,
} from "./middleware/errorHandler.js";

const prisma = new PrismaClient();

const app = express();
const PORT = process.env.PORT || 5000;

// Basic middleware
app.use(requestLogger);
app.use(rateLimit);
app.use(corsHeaders);
app.use(cors());
app.use(express.json({ limit: "10mb" }));
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

// Health check endpoint
app.get("/api/health", (_req, res) => {
  res.json({
    status: "OK",
    message: "Tourism Safety Platform Backend is running!",
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || "development",
    version: "1.0.0",
  });
});

// API Routes
app.use("/api/users", userRoutes);
app.use("/api/trips", tripRoutes);
app.use("/api/alerts", alertRoutes);
app.use("/api/locations", locationRoutes);
app.use("/api/safety", safetyRoutes);
app.use("/api/geofences", geofenceRoutes);

// Legacy endpoints for backward compatibility
app.get("/api/users", async (req, res) => {
  try {
    const users = await prisma.user.findMany();
    res.json(users);
  } catch (error) {
    res.status(500).json({ error: "Failed to fetch users" });
  }
});

app.post("/api/users", async (req, res) => {
  try {
    const user = await prisma.user.create({
      data: req.body,
    });
    res.status(201).json(user);
  } catch (error) {
    res.status(400).json({ error: "Failed to create user" });
  }
});

// Documentation endpoint
app.get("/api/docs", (req, res) => {
  res.json({
    title: "Tourism Safety Platform API",
    version: "1.0.0",
    description: "Backend API for tourist safety monitoring and management",
    endpoints: {
      users: {
        description: "User management and KYC operations",
        routes: {
          "GET /api/users": "Get all users",
          "GET /api/users/:id": "Get user by ID",
          "POST /api/users": "Create new user",
          "PUT /api/users/:id": "Update user",
          "DELETE /api/users/:id": "Delete user",
          "POST /api/users/:id/kyc/aadhar": "Upload Aadhar card (Mock KYC)",
          "GET /api/users/:id/kyc/status": "Get KYC status",
        },
      },
      trips: {
        description: "Trip management operations",
        routes: {
          "GET /api/trips/user/:userId": "Get user trips",
          "GET /api/trips/:id": "Get trip by ID",
          "POST /api/trips": "Create new trip",
          "PUT /api/trips/:id": "Update trip",
          "DELETE /api/trips/:id": "Delete trip",
          "PATCH /api/trips/:id/status": "Update trip status",
        },
      },
      alerts: {
        description: "Alert and SOS management",
        routes: {
          "GET /api/alerts/user/:userId": "Get user alerts",
          "GET /api/alerts/location": "Get alerts by location",
          "GET /api/alerts/:id": "Get alert by ID",
          "POST /api/alerts": "Create new alert",
          "PUT /api/alerts/:id": "Update alert",
          "PATCH /api/alerts/:id/resolve": "Resolve alert",
          "DELETE /api/alerts/:id": "Delete alert",
        },
      },
      locations: {
        description: "Location tracking and history",
        routes: {
          "GET /api/locations/user/:userId": "Get user locations",
          "GET /api/locations/user/:userId/latest": "Get latest location",
          "GET /api/locations/user/:userId/history": "Get location history",
          "GET /api/locations/nearby": "Get nearby locations",
          "POST /api/locations": "Add location data",
          "DELETE /api/locations/:id": "Delete location data",
        },
      },
      safety: {
        description: "Safety score calculation and analysis",
        routes: {
          "GET /api/safety": "Get safety score for location",
          "GET /api/safety/user/:userId": "Get user safety scores",
          "GET /api/safety/area/overview": "Get area safety overview",
          "PUT /api/safety/:id": "Update safety score",
          "DELETE /api/safety/:id": "Delete safety score",
        },
      },
      geofences: {
        description: "Geofence management for safe/danger zones",
        routes: {
          "GET /api/geofences": "Get all geofences",
          "GET /api/geofences/type/:type": "Get geofences by type",
          "GET /api/geofences/area": "Get geofences in area",
          "GET /api/geofences/check": "Check point in geofences",
          "GET /api/geofences/:id": "Get geofence by ID",
          "POST /api/geofences": "Create new geofence",
          "PUT /api/geofences/:id": "Update geofence",
          "DELETE /api/geofences/:id": "Delete geofence",
          "PATCH /api/geofences/:id/toggle": "Toggle geofence status",
        },
      },
    },
    constants: {
      baseUrl: process.env.BASE_URL || `http://localhost:${PORT}`,
      version: "v1",
      supportedFormats: ["JSON"],
    },
  });
});

// Error handling middleware (must be last)
app.use(notFound);
app.use(errorHandler);

// Graceful shutdown
process.on("SIGTERM", async () => {
  console.log("SIGTERM received, shutting down gracefully");
  await prisma.$disconnect();
  process.exit(0);
});

process.on("SIGINT", async () => {
  console.log("SIGINT received, shutting down gracefully");
  await prisma.$disconnect();
  process.exit(0);
});

app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`🌐 Environment: ${process.env.NODE_ENV || "development"}`);
  console.log(`📚 API Documentation: http://localhost:${PORT}/api/docs`);
  console.log(`❤️ Health Check: http://localhost:${PORT}/api/health`);
});
