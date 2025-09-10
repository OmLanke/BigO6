import { PrismaClient } from "../generated/prisma/index.js";
const prisma = new PrismaClient();

// Get all EFIRs (admin only)
export async function getAllEFIRs(req, res) {
    try {
        // Add pagination
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const efirs = await prisma.eFIR.findMany({
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
                        email: true,
                        phoneNumber: true
                    }
                },
                alert: true
            }
        });

        const total = await prisma.eFIR.count();

        res.status(200).json({
            data: efirs,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit)
            }
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve EFIRs',
            details: error.message
        });
    }
}

// Get EFIRs by status
export async function getEFIRsByStatus(req, res) {
    try {
        const { status } = req.params;
        const validStatuses = ['pending', 'investigating', 'resolved', 'closed'];

        if (!validStatuses.includes(status)) {
            return res.status(400).json({ error: 'Invalid status value' });
        }

        // Add pagination
        const page = parseInt(req.query.page) || 1;
        const limit = parseInt(req.query.limit) || 10;
        const skip = (page - 1) * limit;

        const efirs = await prisma.eFIR.findMany({
            where: { status },
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
                        email: true,
                        phoneNumber: true
                    }
                },
                alert: true
            }
        });

        const total = await prisma.eFIR.count({
            where: { status }
        });

        res.status(200).json({
            data: efirs,
            meta: {
                total,
                page,
                limit,
                totalPages: Math.ceil(total / limit),
                status
            }
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve EFIRs',
            details: error.message
        });
    }
}

// Get EFIR by ID
export async function getEFIRById(req, res) {
    try {
        const { id } = req.params;

        const efir = await prisma.eFIR.findUnique({
            where: { id },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        phoneNumber: true,
                        nationality: true
                    }
                },
                alert: true
            }
        });

        if (!efir) {
            return res.status(404).json({ error: 'EFIR not found' });
        }

        res.status(200).json(efir);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve EFIR',
            details: error.message
        });
    }
}

// Get EFIRs by user ID
export async function getEFIRsByUserId(req, res) {
    try {
        const { userId } = req.params;

        const efirs = await prisma.eFIR.findMany({
            where: { userId },
            orderBy: {
                createdAt: 'desc'
            },
            include: {
                alert: true
            }
        });

        res.status(200).json(efirs);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve user EFIRs',
            details: error.message
        });
    }
}

// Get EFIR by alert ID
export async function getEFIRByAlertId(req, res) {
    try {
        const { alertId } = req.params;

        const efir = await prisma.eFIR.findUnique({
            where: { alertId },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        phoneNumber: true
                    }
                },
                alert: true
            }
        });

        if (!efir) {
            return res.status(404).json({ error: 'EFIR not found for this alert' });
        }

        res.status(200).json(efir);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve EFIR',
            details: error.message
        });
    }
}

// Create new EFIR
export async function createEFIR(req, res) {
    try {
        const {
            userId,
            alertId,
            reportType,
            description,
            location,
            latitude,
            longitude,
            filedBy
        } = req.body;

        // Check if user exists
        const user = await prisma.user.findUnique({
            where: { id: userId }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if alert exists (if provided)
        if (alertId) {
            const alert = await prisma.touristAlert.findUnique({
                where: { id: alertId }
            });

            if (!alert) {
                return res.status(404).json({ error: 'Alert not found' });
            }

            // Check if EFIR already exists for this alert
            const existingEFIR = await prisma.eFIR.findUnique({
                where: { alertId }
            });

            if (existingEFIR) {
                return res.status(409).json({
                    error: 'EFIR already exists for this alert',
                    efir: existingEFIR
                });
            }
        }

        // Create new EFIR
        const efir = await prisma.eFIR.create({
            data: {
                userId,
                alertId: alertId || undefined,
                reportType,
                description,
                location,
                latitude,
                longitude,
                filedBy
            },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true
                    }
                },
                alert: true
            }
        });

        res.status(201).json(efir);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to create EFIR',
            details: error.message
        });
    }
}

// Create EFIR from alert
export async function createEFIRFromAlert(req, res) {
    try {
        const { alertId } = req.params;
        const { filedBy, reportType, description } = req.body;

        // Check if alert exists
        const alert = await prisma.touristAlert.findUnique({
            where: { id: alertId }
        });

        if (!alert) {
            return res.status(404).json({ error: 'Alert not found' });
        }

        // Check if EFIR already exists for this alert
        const existingEFIR = await prisma.eFIR.findUnique({
            where: { alertId }
        });

        if (existingEFIR) {
            return res.status(409).json({
                error: 'EFIR already exists for this alert',
                efir: existingEFIR
            });
        }

        // Create EFIR from alert data
        const efir = await prisma.eFIR.create({
            data: {
                userId: alert.userId,
                alertId,
                reportType: reportType || 'emergency', // Default value
                description: description || alert.message, // Use alert message if no description provided
                location: alert.location,
                latitude: alert.latitude,
                longitude: alert.longitude,
                filedBy: filedBy || 'system'
            }
        });

        res.status(201).json(efir);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to create EFIR from alert',
            details: error.message
        });
    }
}

// Update EFIR status
export async function updateEFIRStatus(req, res) {
    try {
        const { id } = req.params;
        const { status } = req.body;

        // Validate status
        const validStatuses = ['pending', 'investigating', 'resolved', 'closed'];
        if (!validStatuses.includes(status)) {
            return res.status(400).json({ error: 'Invalid status value' });
        }

        // Update EFIR status
        const updatedEFIR = await prisma.eFIR.update({
            where: { id },
            data: { status }
        });

        res.status(200).json(updatedEFIR);
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'EFIR not found' });
        }

        res.status(500).json({
            error: 'Failed to update EFIR status',
            details: error.message
        });
    }
}

// Update EFIR details
export async function updateEFIR(req, res) {
    try {
        const { id } = req.params;
        const { reportType, description, location, latitude, longitude } = req.body;

        // Update EFIR
        const updatedEFIR = await prisma.eFIR.update({
            where: { id },
            data: {
                reportType: reportType || undefined,
                description: description || undefined,
                location: location || undefined,
                latitude: latitude || undefined,
                longitude: longitude || undefined
            }
        });

        res.status(200).json(updatedEFIR);
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'EFIR not found' });
        }

        res.status(500).json({
            error: 'Failed to update EFIR',
            details: error.message
        });
    }
}

// Delete EFIR
export async function deleteEFIR(req, res) {
    try {
        const { id } = req.params;

        await prisma.eFIR.delete({
            where: { id }
        });

        res.status(200).json({ message: 'EFIR deleted successfully' });
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'EFIR not found' });
        }

        res.status(500).json({
            error: 'Failed to delete EFIR',
            details: error.message
        });
    }
}
