// Global error handling middleware
export const errorHandler = (err, req, res, next) => {
  console.error('Error Details:', {
    message: err.message,
    stack: err.stack,
    url: req.url,
    method: req.method,
    timestamp: new Date().toISOString()
  });

  // Default error
  let error = {
    success: false,
    message: 'Internal Server Error'
  };

  // Prisma errors
  if (err.code) {
    switch (err.code) {
      case 'P2002':
        error.message = 'A record with this information already exists';
        error.statusCode = 400;
        break;
      case 'P2025':
        error.message = 'Record not found';
        error.statusCode = 404;
        break;
      case 'P2003':
        error.message = 'Foreign key constraint failed';
        error.statusCode = 400;
        break;
      case 'P2014':
        error.message = 'Invalid ID provided';
        error.statusCode = 400;
        break;
      default:
        error.message = 'Database operation failed';
        error.statusCode = 500;
    }
  }

  // Validation errors
  if (err.name === 'ValidationError') {
    error.message = 'Validation failed';
    error.details = err.errors;
    error.statusCode = 400;
  }

  // JWT errors
  if (err.name === 'JsonWebTokenError') {
    error.message = 'Invalid token';
    error.statusCode = 401;
  }

  if (err.name === 'TokenExpiredError') {
    error.message = 'Token expired';
    error.statusCode = 401;
  }

  // Custom API errors
  if (err.statusCode) {
    error.statusCode = err.statusCode;
    error.message = err.message;
  }

  const statusCode = error.statusCode || 500;

  res.status(statusCode).json({
    success: false,
    message: error.message,
    ...(process.env.NODE_ENV === 'development' && { 
      stack: err.stack,
      details: error.details 
    })
  });
};

// Not found middleware
export const notFound = (req, res, next) => {
  const error = new Error(`Not Found - ${req.originalUrl}`);
  error.statusCode = 404;
  next(error);
};

// Request logging middleware
export const requestLogger = (req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path} - IP: ${req.ip}`);
  next();
};

// CORS headers middleware
export const corsHeaders = (req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, PATCH, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Origin, X-Requested-With, Content-Type, Accept, Authorization');
  
  if (req.method === 'OPTIONS') {
    res.sendStatus(200);
  } else {
    next();
  }
};

// Rate limiting middleware (basic implementation)
const requestCounts = new Map();
const RATE_LIMIT_WINDOW = 15 * 60 * 1000; // 15 minutes
const MAX_REQUESTS = 100; // max requests per window

export const rateLimit = (req, res, next) => {
  const ip = req.ip;
  const now = Date.now();
  
  if (!requestCounts.has(ip)) {
    requestCounts.set(ip, { count: 1, resetTime: now + RATE_LIMIT_WINDOW });
    return next();
  }
  
  const record = requestCounts.get(ip);
  
  if (now > record.resetTime) {
    record.count = 1;
    record.resetTime = now + RATE_LIMIT_WINDOW;
    return next();
  }
  
  if (record.count >= MAX_REQUESTS) {
    return res.status(429).json({
      success: false,
      message: 'Too many requests, please try again later'
    });
  }
  
  record.count++;
  next();
};
