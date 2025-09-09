import express from 'express';
import {
  recordLocation,
  getUserLocationHistory,
  getCurrentLocation,
  getLocationsByTimeRange
} from '../controllers/locationController.js';

const router = express.Router();

// Location data operations
router.get('/user/:userId', getUserLocationHistory);
router.get('/user/:userId/latest', getCurrentLocation);
router.get('/user/:userId/history', getLocationsByTimeRange);
router.post('/', recordLocation);

export default router;
