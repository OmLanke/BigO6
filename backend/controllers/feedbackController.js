const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Get all feedback entries
exports.getAllFeedback = async (req, res) => {
    try {
        // Add pagination
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const feedback = await prisma.feedback.findMany({
            skip,
            take: limit,
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            }
        });

        const total = await prisma.feedback.count();

        res.status(200).json({
            data: feedback,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve feedback',
            details: error.message
        });
    }
};

// Get feedback statistics (for dashboard)
exports.getFeedbackStats = async (req, res) => {
    try {
        // Get total feedback count
        const totalCount = await prisma.feedback.count();

        // Get average rating
        const averageRatingResult = await prisma.feedback.aggregate({
            _avg: {
                rating: true
            }
        });
        const averageRating = averageRatingResult._avg.rating || 0;

        // Get count by category
        const categories = await prisma.feedback.groupBy({
            by: ['category'],
            _count: {
                category: true
            },
            _avg: {
                rating: true
            }
        });

        // Get rating distribution
        const ratingDistribution = await prisma.feedback.groupBy({
            by: ['rating'],
            _count: {
                rating: true
            }
        });

        // Get recent feedback (last 7 days)
        const oneWeekAgo = new Date();
        oneWeekAgo.setDate(oneWeekAgo.getDate() - 7);

        const recentCount = await prisma.feedback.count({
            where: {
                createdAt: {
                    gte: oneWeekAgo
                }
            }
        });

        res.status(200).json({
            totalCount,
            averageRating,
            categoryBreakdown: categories.map(cat => ({
                category: cat.category,
                count: cat._count.category,
                averageRating: cat._avg.rating || 0
            })),
            ratingDistribution: ratingDistribution.map(rating => ({
                rating: rating.rating,
                count: rating._count.rating
            })),
            recentCount
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve feedback statistics',
            details: error.message
        });
    }
};

// Get feedback by category
exports.getFeedbackByCategory = async (req, res) => {
    try {
        const { category } = req.params;

        // Add pagination
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const feedback = await prisma.feedback.findMany({
            where: { category },
            skip,
            take: limit,
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true
                    }
                }
            }
        });

        const total = await prisma.feedback.count({
            where: { category }
        });

        res.status(200).json({
            data: feedback,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
                category
            }
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve feedback by category',
            details: error.message
        });
    }
};

// Get feedback by ID
exports.getFeedbackById = async (req, res) => {
    try {
        const { id } = req.params;

        const feedback = await prisma.feedback.findUnique({
            where: { id },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                }
            }
        });

        if (!feedback) {
            return res.status(404).json({ error: 'Feedback not found' });
        }

        res.status(200).json(feedback);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve feedback',
            details: error.message
        });
    }
};

// Get feedback by user ID
exports.getFeedbackByUserId = async (req, res) => {
    try {
        const { userId } = req.params;

        const feedback = await prisma.feedback.findMany({
            where: { userId },
            orderBy: {
                createdAt: 'desc'
            }
        });

        res.status(200).json(feedback);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve user feedback',
            details: error.message
        });
    }
};

// Create new feedback
exports.createFeedback = async (req, res) => {
    try {
        const { userId, rating, category, comment } = req.body;

        // Validate rating
        if (rating < 1 || rating > 5) {
            return res.status(400).json({ error: 'Rating must be between 1 and 5' });
        }

        // Check if user exists
        const user = await prisma.user.findUnique({
            where: { id: userId }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Create feedback
        const feedback = await prisma.feedback.create({
            data: {
                userId,
                rating,
                category,
                comment
            }
        });

        res.status(201).json(feedback);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to create feedback',
            details: error.message
        });
    }
};

// Delete feedback
exports.deleteFeedback = async (req, res) => {
    try {
        const { id } = req.params;

        await prisma.feedback.delete({
            where: { id }
        });

        res.status(200).json({ message: 'Feedback deleted successfully' });
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'Feedback not found' });
        }

        res.status(500).json({
            error: 'Failed to delete feedback',
            details: error.message
        });
    }
};
