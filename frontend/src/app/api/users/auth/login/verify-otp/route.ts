import { NextRequest, NextResponse } from 'next/server';

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    
    // Forward the request to your backend
    const backendUrl = process.env.BACKEND_URL || 'http://localhost:5000';
    
    const response = await fetch(`${backendUrl}/api/users/auth/login/verify-otp`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(body),
    });

    const data = await response.json();
    
    // If login is successful, you could set cookies or session here
    if (data.success) {
      // For now, just return the user data
      // In a real app, you'd want to set secure session cookies
      console.log('User logged in successfully:', data.data.user.email);
    }
    
    return NextResponse.json(data, { status: response.status });
  } catch (error) {
    console.error('Error in verify-otp API:', error);
    return NextResponse.json(
      { success: false, message: 'Internal server error' },
      { status: 500 }
    );
  }
}
