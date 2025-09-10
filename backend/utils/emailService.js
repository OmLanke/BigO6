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
export const sendOTPEmail = async (email, otp, type = 'registration') => {
    const isLogin = type === 'login';
    
    const mailOptions = {
        from: process.env.GMAIL_USER || 'oplanke@gmail.com', // Get from environment variable
        to: email,
        subject: isLogin ? 'Your Login Code - Tourist Safety App' : 'Your Verification Code - Tourist Safety App',
        text: `Your ${isLogin ? 'login' : 'verification'} code is: ${otp}. It will expire in 5 minutes.`,
        html: `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #e0e0e0; border-radius: 10px; background-color: #fafafa;">
        <div style="text-align: center; margin-bottom: 20px;">
          <h1 style="color: #2563eb; margin: 0; font-size: 24px;">🛡️ Tourist Safety App</h1>
        </div>
        
        <div style="background-color: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
          <h2 style="color: #333; margin-top: 0;">
            ${isLogin ? '🔐 Login Verification' : '✉️ Email Verification'}
          </h2>
          <p style="color: #555; font-size: 16px;">
            ${isLogin 
              ? 'Welcome back! Use the code below to access your account:' 
              : 'Thank you for signing up! Use the code below to verify your email:'
            }
          </p>
          
          <div style="background-color: #f8fafc; padding: 20px; margin: 20px 0; border-radius: 8px; border-left: 4px solid #2563eb;">
            <h1 style="font-size: 36px; letter-spacing: 8px; color: #2563eb; margin: 0; text-align: center; font-weight: bold;">${otp}</h1>
          </div>
          
          <div style="background-color: #fef3cd; padding: 15px; border-radius: 6px; border-left: 4px solid #f59e0b; margin: 20px 0;">
            <p style="margin: 0; color: #92400e; font-size: 14px;">
              ⏰ This code will expire in <strong>5 minutes</strong> for security reasons.
            </p>
          </div>
          
          <p style="color: #555; font-size: 14px;">
            ${isLogin 
              ? 'If you didn\'t attempt to log in, please secure your account immediately.' 
              : 'If you didn\'t create an account, please ignore this email.'
            }
          </p>
        </div>
        
        <div style="text-align: center; margin-top: 20px;">
          <p style="font-size: 12px; color: #777;">
            This is an automated email from Tourist Safety Monitoring System
          </p>
        </div>
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
