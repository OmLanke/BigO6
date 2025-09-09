import express from 'express';
import {
  getGeofences,
  getGeofenceById,
  createGeofence,
  updateGeofence,
  deleteGeofence,
  checkPointInGeofences,
  getGeofencesByType,
  getGeofencesInArea,
  toggleGeofenceStatus
} from '../controllers/geofenceController.js';

const router = express.Router();

// Geofence CRUD operations
router.get('/', getGeofences);
router.get('/type/:type', getGeofencesByType);
router.get('/area', getGeofencesInArea);
router.get('/check', checkPointInGeofences);
router.get('/:id', getGeofenceById);
router.post('/', createGeofence);
router.put('/:id', updateGeofence);
router.delete('/:id', deleteGeofence);

// Geofence status management
router.patch('/:id/toggle', toggleGeofenceStatus);

export default router;
