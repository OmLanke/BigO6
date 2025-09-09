# BigO6 Backend

Backend services for the BigO6 travel app.

## Setup

1. Install dependencies:
   ```
   npm install
   ```

2. Set up environment variables:
   - Copy `.env.template` to `.env`
   - Fill in your Gmail credentials:
     ```
     GMAIL_USER=your.email@gmail.com
     GOOGLE_APP_PASSWORD=your_app_password_here
     ```

3. Set up Gmail App Password:
   - Go to your Google Account > Security
   - Enable 2-Step Verification if not already enabled
   - Go to "App passwords" and generate a password for your app
   - Copy the generated app password to your `.env` file

4. Start the server:
   ```
   npm start
   ```

## API Endpoints

### Email Verification
- `POST /api/users/auth/send-otp`: Send an OTP to a user's email
- `POST /api/users/auth/verify-otp`: Verify the OTP and create initial user
- `POST /api/users/:id/complete-registration`: Complete the user registration

### User Management
- `GET /api/users`: Get all users
- `GET /api/users/:id`: Get a user by ID
- `POST /api/users`: Create a new user
- `PUT /api/users/:id`: Update a user
- `DELETE /api/users/:id`: Delete a user

### KYC Operations
- `POST /api/users/:id/kyc/aadhar`: Upload Aadhar card
- `GET /api/users/:id/kyc/status`: Get KYC status

## Development

### Running in Development Mode
```
npm run dev
```

### Database Migrations
```
npx prisma migrate dev
```
