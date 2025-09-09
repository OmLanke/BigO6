import nodemailer from 'nodemailer';

// Configure nodemailer with Gmail
// Get credentials from environment variables
const transporter = nodemailer.createTransport({
    service: 'gmail',
    auth: {
        user: process.env.GMAIL_USER || 'oplanke@gmail.com',
        pass: process.env.GOOGLE_APP_PASSWORD || ''  // Get from environment variable
    }
});

// In-memory OTP cache (for production use Redis or similar)
export const otpCache = new Map();

// OTP expiry time in milliseconds (5 minutes)
const OTP_EXPIRY = 5 * 60 * 1000;

// Generate a random 6-digit OTP
export const generateOTP = () => {
    return Math.floor(100000 + Math.random() * 900000).toString();
};

// Store OTP with expiry
export const storeOTP = (email, otp) => {
    otpCache.set(email, {
        otp,
        expiry: Date.now() + OTP_EXPIRY
    });
};

// Verify OTP
export const verifyOTP = (email, otp) => {
    const otpData = otpCache.get(email);

    if (!otpData) {
        return { valid: false, message: 'No OTP found for this email' };
    }

    if (Date.now() > otpData.expiry) {
        otpCache.delete(email); // Clean up expired OTP
        return { valid: false, message: 'OTP has expired' };
    }

    if (otpData.otp !== otp) {
        return { valid: false, message: 'Invalid OTP' };
    }

    // OTP is valid, clean it up
    otpCache.delete(email);
    return { valid: true, message: 'OTP verified successfully' };
};

// Send OTP via email
export const sendOTPEmail = async (email, otp) => {
    const mailOptions = {
        from: process.env.GMAIL_USER || 'oplanke@gmail.com', // Get from environment variable
        to: email,
        subject: 'Your Verification Code',
        text: `Your verification code is: ${otp}. It will expire in 5 minutes.`,
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px;">
        <h2 style="color: #333;">Email Verification</h2>
        <p>Your verification code is:</p>
        <h1 style="font-size: 32px; letter-spacing: 5px; background-color: #f5f5f5; padding: 10px; text-align: center; border-radius: 5px;">${otp}</h1>
        <p>This code will expire in 5 minutes.</p>
        <p style="font-size: 12px; color: #777; margin-top: 30px;">If you did not request this code, please ignore this email.</p>
      </div>
    `
    };

    try {
        const info = await transporter.sendMail(mailOptions);
        return { success: true, messageId: info.messageId };
    } catch (error) {
        console.error('Error sending email:', error);
        throw new Error('Failed to send OTP email');
    }
};
