const express = require('express');
const efirController = require('../controllers/efirController');
const { validateEFIR, validateUUID } = require('../middleware/validation');

const router = express.Router();

// GET all EFIRs (admin only)
router.get('/', efirController.getAllEFIRs);

// GET EFIRs by status
router.get('/status/:status', efirController.getEFIRsByStatus);

// GET EFIR by ID
router.get('/:id', validateUUID('id'), efirController.getEFIRById);

// GET EFIRs by user ID
router.get('/user/:userId', validateUUID('userId'), efirController.getEFIRsByUserId);

// GET EFIR by alert ID
router.get('/alert/:alertId', validateUUID('alertId'), efirController.getEFIRByAlertId);

// POST create new EFIR
router.post('/', validateEFIR, efirController.createEFIR);

// POST create EFIR from alert
router.post('/from-alert/:alertId', validateUUID('alertId'), efirController.createEFIRFromAlert);

// PATCH update EFIR status
router.patch('/:id/status', validateUUID('id'), validateEFIR, efirController.updateEFIRStatus);

// PUT update EFIR details
router.put('/:id', validateUUID('id'), validateEFIR, efirController.updateEFIR);

// DELETE EFIR
router.delete('/:id', validateUUID('id'), efirController.deleteEFIR);

module.exports = router;
