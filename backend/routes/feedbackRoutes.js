const express = require('express');
const feedbackController = require('../controllers/feedbackController');
const { validateFeedback, validateUUID } = require('../middleware/validation');

const router = express.Router();

// GET all feedback entries (admin)
router.get('/', feedbackController.getAllFeedback);

// GET feedback statistics (for dashboard)
router.get('/stats', feedbackController.getFeedbackStats);

// GET feedback by category
router.get('/category/:category', feedbackController.getFeedbackByCategory);

// GET feedback by ID
router.get('/:id', validateUUID('id'), feedbackController.getFeedbackById);

// GET feedback by user ID
router.get('/user/:userId', validateUUID('userId'), feedbackController.getFeedbackByUserId);

// POST submit new feedback
router.post('/', validateFeedback, feedbackController.createFeedback);

// DELETE feedback
router.delete('/:id', validateUUID('id'), feedbackController.deleteFeedback);

module.exports = router;
