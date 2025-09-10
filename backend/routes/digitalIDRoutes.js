import { Router } from 'express';
import { getAllDigitalIDs, getDigitalIDCount, getDigitalIDById, getDigitalIDByUserId, issueDigitalID, updateDigitalIDStatus, revokeDigitalID } from '../controllers/digitalIDController.js';
import { validateDigitalID, validateUUID } from '../middleware/validation.js';

const router = Router();

// GET all digital IDs (admin only)
router.get('/', getAllDigitalIDs);

// GET count of digital IDs (for dashboard)
router.get('/count', getDigitalIDCount);

// GET single digital ID by ID
router.get('/:id', validateUUID('id'), getDigitalIDById);

// GET digital ID by user ID
router.get('/user/:userId', validateUUID('userId'), getDigitalIDByUserId);

// POST issue new digital ID
router.post('/', validateDigitalID, issueDigitalID);

// PATCH update digital ID status
router.patch('/:id', validateUUID('id'), validateDigitalID, updateDigitalIDStatus);

// DELETE digital ID (revoke)
router.delete('/:id', validateUUID('id'), revokeDigitalID);

export default router;
