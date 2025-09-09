import mongoose from "mongoose";

const connectDB = async () => {
  try {
    const mongoURI =
      process.env.MONGODB_URI || "mongodb://localhost:27017/tourism-safety";

    const conn = await mongoose.connect(mongoURI, {
      // These options are no longer needed in Mongoose 6+, but included for compatibility
      // useNewUrlParser: true,
      // useUnifiedTopology: true,
    });

    console.log(`MongoDB Connected: ${conn.connection.host}`);
    console.log(`Database: ${conn.connection.name}`);

    // Handle connection events
    mongoose.connection.on("error", (err) => {
      console.error("MongoDB connection error:", err);
    });

    mongoose.connection.on("disconnected", () => {
      console.log("MongoDB disconnected");
    });

    // Graceful shutdown
    process.on("SIGINT", async () => {
      try {
        await mongoose.connection.close();
        console.log("MongoDB connection closed through app termination");
      } catch (error) {
        console.log("Error closing MongoDB connection:", error.message);
      }
      process.exit(0);
    });
  } catch (error) {
    console.warn(
      "MongoDB connection failed (continuing without MongoDB):",
      error.message
    );
    // Don't exit the process, let the app continue with Prisma
  }
};

export default connectDB;
