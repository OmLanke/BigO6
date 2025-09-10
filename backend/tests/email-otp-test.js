// This file provides a simple test for the email OTP endpoints
// Rename this file to test.js and run it with: node test.js

import fetch from 'node-fetch';

const BASE_URL = 'http://localhost:8000'; // Adjust if your server runs on a different port

// Test the OTP flow
const testOTPFlow = async () => {
    try {
        const email = 'test@example.com'; // Replace with your test email

        console.log('Step 1: Sending OTP to email...');
        const sendOTPResponse = await fetch(`${BASE_URL}/api/users/auth/send-otp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email })
        });

        const sendResult = await sendOTPResponse.json();
        console.log('Send OTP Result:', sendResult);

        if (!sendResult.success) {
            throw new Error('Failed to send OTP');
        }

        // In a real test, you'd need to get the OTP from the email
        // For testing, you can manually check the console logs in your server or the in-memory otpCache
        const otp = '123456'; // Replace with the actual OTP

        console.log('Step 2: Verifying OTP...');
        const verifyOTPResponse = await fetch(`${BASE_URL}/api/users/auth/verify-otp`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, otp })
        });

        const verifyResult = await verifyOTPResponse.json();
        console.log('Verify OTP Result:', verifyResult);

        if (!verifyResult.success || !verifyResult.data.userId) {
            throw new Error('Failed to verify OTP');
        }

        const userId = verifyResult.data.userId;

        console.log('Step 3: Completing user registration...');
        const completeRegistrationResponse = await fetch(`${BASE_URL}/api/users/${userId}/complete-registration`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                name: 'Test User',
                phoneNumber: '1234567890',
                nationality: 'Indian',
                dateOfBirth: '1990-01-01'
            })
        });

        const completeResult = await completeRegistrationResponse.json();
        console.log('Complete Registration Result:', completeResult);

        if (!completeResult.success) {
            throw new Error('Failed to complete registration');
        }

        console.log('OTP flow test completed successfully!');
    } catch (error) {
        console.error('Test failed:', error.message);
    }
};

// Run the test
testOTPFlow();
