# Flutter Backend Integration Guide

## Overview
This backend is now fully integrated with blockchain functionality and ready for Flutter integration. The system combines PostgreSQL database operations with smart contract interactions.

## API Endpoints

### User Management

#### 1. Register User on Blockchain
```
POST /api/users/:id/blockchain/register
```
Registers an existing user on the blockchain after they're created in the database.

**Response:**
```json
{
  "success": true,
  "message": "User registered on blockchain successfully",
  "data": {
    "touristId": "1",
    "transactionHash": "0x..."
  }
}
```

#### 2. Get User Blockchain Data
```
GET /api/users/:id/blockchain
```
Retrieves blockchain-specific data for a user.

**Response:**
```json
{
  "success": true,
  "data": {
    "touristId": "1",
    "name": "John Doe",
    "email": "john@example.com",
    "registrationDate": "2024-01-01T00:00:00Z",
    "totalTrips": 5,
    "isActive": true
  }
}
```

#### 3. Get Blockchain Statistics
```
GET /api/users/blockchain/stats
```
Get overall blockchain statistics.

**Response:**
```json
{
  "success": true,
  "data": {
    "totalTourists": 150,
    "totalTrips": 500,
    "activeUsers": 120
  }
}
```

### Trip Management

#### 1. Register Trip on Blockchain
```
POST /api/trips/:id/blockchain/register
```
Registers an existing trip on the blockchain.

**Response:**
```json
{
  "success": true,
  "message": "Trip registered on blockchain successfully",
  "data": {
    "tripId": "1",
    "transactionHash": "0x..."
  }
}
```

#### 2. Verify Trip on Blockchain
```
POST /api/trips/:id/blockchain/verify
```
Verifies trip authenticity on blockchain.

**Response:**
```json
{
  "success": true,
  "data": {
    "isValid": true,
    "tripId": "1",
    "touristId": "1",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

#### 3. Get Trip Blockchain Data
```
GET /api/trips/:id/blockchain
```
Retrieves blockchain-specific data for a trip.

## Flutter Integration Steps

### 1. HTTP Client Setup
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  
  static Future<Map<String, dynamic>> registerUserOnBlockchain(String userId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/$userId/blockchain/register'),
      headers: {'Content-Type': 'application/json'},
    );
    
    return json.decode(response.body);
  }
}
```

### 2. User Registration Flow
```dart
// 1. Create user in database (existing functionality)
final user = await createUser(userData);

// 2. Register user on blockchain
if (user.success) {
  final blockchainResult = await ApiService.registerUserOnBlockchain(user.data.id);
  if (blockchainResult['success']) {
    // Show success message
    print('User registered on blockchain: ${blockchainResult['data']['touristId']}');
  }
}
```

### 3. Trip Registration Flow
```dart
// 1. Create trip in database (existing functionality)
final trip = await createTrip(tripData);

// 2. Register trip on blockchain
if (trip.success) {
  final blockchainResult = await ApiService.registerTripOnBlockchain(trip.data.id);
  if (blockchainResult['success']) {
    // Show success message
    print('Trip registered on blockchain: ${blockchainResult['data']['tripId']}');
  }
}
```

### 4. Data Models
```dart
class BlockchainUser {
  final String touristId;
  final String name;
  final String email;
  final DateTime registrationDate;
  final int totalTrips;
  final bool isActive;
  
  BlockchainUser.fromJson(Map<String, dynamic> json)
    : touristId = json['touristId'],
      name = json['name'],
      email = json['email'],
      registrationDate = DateTime.parse(json['registrationDate']),
      totalTrips = json['totalTrips'],
      isActive = json['isActive'];
}

class BlockchainTrip {
  final String tripId;
  final String touristId;
  final String itinerary;
  final DateTime timestamp;
  final bool isValid;
  
  BlockchainTrip.fromJson(Map<String, dynamic> json)
    : tripId = json['tripId'],
      touristId = json['touristId'],
      itinerary = json['itinerary'],
      timestamp = DateTime.parse(json['timestamp']),
      isValid = json['isValid'] ?? true;
}
```

## Smart Contract Integration

The backend automatically handles:
- User registration on blockchain when requested
- Trip registration with complete itinerary data
- Verification of trip authenticity
- Retrieval of blockchain statistics
- Error handling for blockchain operations

## Database Schema Updates

New fields added to support blockchain integration:

### User Model
- `blockchainId`: Tourist ID on blockchain (String, optional)

### Trip Model
- `blockchainId`: Trip ID on blockchain (String, optional)
- `destination`: Trip destination (String, optional)
- `itinerary`: Trip itinerary as JSON (Json, optional)

## Environment Setup

Before running the backend, update the `.env` file with:

```env
# Blockchain Configuration
PRIVATE_KEY="your_wallet_private_key_here"
RPC_URL="https://your-blockchain-rpc-url.com"
TOURIST_REGISTRY_ADDRESS="0x_your_deployed_contract_address"
```

## Testing the Integration

1. Start the backend server:
   ```bash
   npm start
   ```

2. Test user blockchain registration:
   ```bash
   curl -X POST http://localhost:5000/api/users/{userId}/blockchain/register
   ```

3. Test trip blockchain registration:
   ```bash
   curl -X POST http://localhost:5000/api/trips/{tripId}/blockchain/register
   ```

## Error Handling

The backend handles various error scenarios:
- User not found
- User not registered on blockchain
- Blockchain connection issues
- Smart contract interaction failures
- Invalid trip data

All errors return standardized JSON responses with appropriate HTTP status codes.

## Next Steps for Flutter

1. Update your Flutter app to use these new API endpoints
2. Implement blockchain status indicators in the UI
3. Add loading states for blockchain operations
4. Handle blockchain-specific errors gracefully
5. Consider adding blockchain verification badges for users and trips

The backend is now fully prepared for Flutter integration with comprehensive blockchain functionality!
