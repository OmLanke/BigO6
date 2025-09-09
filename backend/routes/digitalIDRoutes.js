const express = require('express');
const digitalIDController = require('../controllers/digitalIDController');
const { validateDigitalID, validateUUID } = require('../middleware/validation');

const router = express.Router();

// GET all digital IDs (admin only)
router.get('/', digitalIDController.getAllDigitalIDs);

// GET count of digital IDs (for dashboard)
router.get('/count', digitalIDController.getDigitalIDCount);

// GET single digital ID by ID
router.get('/:id', validateUUID('id'), digitalIDController.getDigitalIDById);

// GET digital ID by user ID
router.get('/user/:userId', validateUUID('userId'), digitalIDController.getDigitalIDByUserId);

// POST issue new digital ID
router.post('/', validateDigitalID, digitalIDController.issueDigitalID);

// PATCH update digital ID status
router.patch('/:id', validateUUID('id'), validateDigitalID, digitalIDController.updateDigitalIDStatus);

// DELETE digital ID (revoke)
router.delete('/:id', validateUUID('id'), digitalIDController.revokeDigitalID);

module.exports = router;
