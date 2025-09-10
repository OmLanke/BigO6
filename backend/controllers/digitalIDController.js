import { PrismaClient } from "../generated/prisma/index.js";
const prisma = new PrismaClient();

// Helper function to generate unique ID number
const generateUniqueIDNumber = async () => {
    // Example format: DID-YYYY-XXXXX (where X is random number)
    const year = new Date().getFullYear();
    const randomPart = Math.floor(10000 + Math.random() * 90000); // 5-digit number
    const idNumber = `DID-${year}-${randomPart}`;

    // Check if ID already exists
    const existingID = await prisma.digitalID.findUnique({
        where: { idNumber }
    });

    if (existingID) {
        // Recursively try again if ID already exists
        return generateUniqueIDNumber();
    }

    return idNumber;
};

// Get all digital IDs (admin only)
export async function getAllDigitalIDs(req, res) {
    try {
        const digitalIDs = await prisma.digitalID.findMany({
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        nationality: true,
                        phoneNumber: true,
                        profileImageUrl: true
                    }
                }
            }
        });

        res.status(200).json(digitalIDs);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve digital IDs',
            details: error.message
        });
    }
}

// Get count of digital IDs (for dashboard)
export async function getDigitalIDCount(req, res) {
    try {
        const count = await prisma.digitalID.count();

        // Optional: Get counts by status
        const activeCount = await prisma.digitalID.count({
            where: { status: 'active' }
        });

        const expiredCount = await prisma.digitalID.count({
            where: { status: 'expired' }
        });

        const revokedCount = await prisma.digitalID.count({
            where: { status: 'revoked' }
        });

        res.status(200).json({
            totalCount: count,
            activeCount,
            expiredCount,
            revokedCount
        });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve digital ID count',
            details: error.message
        });
    }
}

// Get single digital ID by ID
export async function getDigitalIDById(req, res) {
    try {
        const { id } = req.params;

        const digitalID = await prisma.digitalID.findUnique({
            where: { id },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        nationality: true,
                        phoneNumber: true,
                        profileImageUrl: true
                    }
                }
            }
        });

        if (!digitalID) {
            return res.status(404).json({ error: 'Digital ID not found' });
        }

        res.status(200).json(digitalID);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve digital ID',
            details: error.message
        });
    }
}

// Get digital ID by user ID
export async function getDigitalIDByUserId(req, res) {
    try {
        const { userId } = req.params;

        const digitalID = await prisma.digitalID.findUnique({
            where: { userId },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        nationality: true,
                        phoneNumber: true,
                        profileImageUrl: true
                    }
                }
            }
        });

        if (!digitalID) {
            return res.status(404).json({ error: 'Digital ID not found for this user' });
        }

        res.status(200).json(digitalID);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to retrieve digital ID',
            details: error.message
        });
    }
}

// Issue new digital ID
export async function issueDigitalID(req, res) {
    try {
        const { userId, expiresAt } = req.body;

        // Check if user exists
        const user = await prisma.user.findUnique({
            where: { id: userId }
        });

        if (!user) {
            return res.status(404).json({ error: 'User not found' });
        }

        // Check if user already has a digital ID
        const existingID = await prisma.digitalID.findUnique({
            where: { userId }
        });

        if (existingID) {
            return res.status(409).json({
                error: 'User already has a digital ID',
                digitalID: existingID
            });
        }

        // Generate a unique ID number
        const idNumber = await generateUniqueIDNumber();

        // Create new digital ID
        const digitalID = await prisma.digitalID.create({
            data: {
                userId,
                idNumber,
                expiresAt: expiresAt ? new Date(expiresAt) : undefined,
                status: 'active'
            },
            include: {
                user: {
                    select: {
                        id: true,
                        name: true,
                        email: true,
                        nationality: true,
                        phoneNumber: true
                    }
                }
            }
        });

        res.status(201).json(digitalID);
    } catch (error) {
        res.status(500).json({
            error: 'Failed to issue digital ID',
            details: error.message
        });
    }
}

// Update digital ID status
export async function updateDigitalIDStatus(req, res) {
    try {
        const { id } = req.params;
        const { status, expiresAt } = req.body;

        // Validate status
        const validStatuses = ['active', 'expired', 'revoked'];
        if (status && !validStatuses.includes(status)) {
            return res.status(400).json({ error: 'Invalid status value' });
        }

        // Update digital ID
        const updatedDigitalID = await prisma.digitalID.update({
            where: { id },
            data: {
                status: status || undefined,
                expiresAt: expiresAt ? new Date(expiresAt) : undefined
            }
        });

        res.status(200).json(updatedDigitalID);
    } catch (error) {
        if (error.code === 'P2025') {
            return res.status(404).json({ error: 'Digital ID not found' });
        }

        res.status(500).json({
            error: 'Failed to update digital ID',
            details: error.message
        });
    }
}

// Revoke digital ID
export async function revokeDigitalID(req, res) {
    try {
        const { id } = req.params;

        // Check if digital ID exists
        const digitalID = await prisma.digitalID.findUnique({
            where: { id }
        });

        if (!digitalID) {
            return res.status(404).json({ error: 'Digital ID not found' });
        }

        // Update status to revoked
        await prisma.digitalID.update({
            where: { id },
            data: { status: 'revoked' }
        });

        res.status(200).json({ message: 'Digital ID revoked successfully' });
    } catch (error) {
        res.status(500).json({
            error: 'Failed to revoke digital ID',
            details: error.message
        });
    }
}
