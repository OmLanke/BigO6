import { Router } from 'express';
import { getAllFeedback, getFeedbackStats, getFeedbackByCategory, getFeedbackById, getFeedbackByUserId, createFeedback, deleteFeedback } from '../controllers/feedbackController.js';
import { validateFeedback, validateUUID } from '../middleware/validation.js';

const router = Router();

// GET all feedback entries (admin)
router.get('/', getAllFeedback);

// GET feedback statistics (for dashboard)
router.get('/stats', getFeedbackStats);

// GET feedback by category
router.get('/category/:category', getFeedbackByCategory);

// GET feedback by ID
router.get('/:id', validateUUID('id'), getFeedbackById);

// GET feedback by user ID
router.get('/user/:userId', validateUUID('userId'), getFeedbackByUserId);

// POST submit new feedback
router.post('/', validateFeedback, createFeedback);

// DELETE feedback
router.delete('/:id', validateUUID('id'), deleteFeedback);

export default router;
