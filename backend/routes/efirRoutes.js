import { Router } from 'express';
import { getAllEFIRs, getEFIRsByStatus, getEFIRById, getEFIRsByUserId, getEFIRByAlertId, createEFIR, createEFIRFromAlert, updateEFIRStatus, updateEFIR, deleteEFIR } from '../controllers/efirController.js';
import { validateEFIR, validateUUID } from '../middleware/validation.js';

const router = Router();

// GET all EFIRs (admin only)
router.get('/', getAllEFIRs);

// GET EFIRs by status
router.get('/status/:status', getEFIRsByStatus);

// GET EFIR by ID
router.get('/:id', validateUUID('id'), getEFIRById);

// GET EFIRs by user ID
router.get('/user/:userId', validateUUID('userId'), getEFIRsByUserId);

// GET EFIR by alert ID
router.get('/alert/:alertId', validateUUID('alertId'), getEFIRByAlertId);

// POST create new EFIR
router.post('/', validateEFIR, createEFIR);

// POST create EFIR from alert
router.post('/from-alert/:alertId', validateUUID('alertId'), createEFIRFromAlert);

// PATCH update EFIR status
router.patch('/:id/status', validateUUID('id'), validateEFIR, updateEFIRStatus);

// PUT update EFIR details
router.put('/:id', validateUUID('id'), validateEFIR, updateEFIR);

// DELETE EFIR
router.delete('/:id', validateUUID('id'), deleteEFIR);

export default router;
