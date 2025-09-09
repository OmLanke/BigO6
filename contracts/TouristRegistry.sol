// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This contract serves as a tamper-proof registry for tourist IDs and trips.
// It links a user to a unique ID in our secure, off-chain database.
contract TouristRegistry {

    address public owner;

    // A struct to hold a tourist's minimal, verifiable data.
    // Only the hash of the unique Postgres ID is stored on-chain for privacy.
    struct Tourist {
        bytes32 offChainIdHash; // Hash of unique Postgres DB ID
        bool isRegistered;
    }

    // A struct for a trip, storing all trip data on-chain, linked to the tourist ID.
    struct Trip {
        uint256 touristId;
        uint256 startDate;
        uint256 endDate;
        string itinerary; // Store full itinerary or trip data as a string (JSON or any format)
    }

    mapping(uint256 => Tourist) public tourists;
    mapping(uint256 => Trip) public trips;
    uint256 public nextTouristId = 0;
    uint256 public nextTripId = 0;

    // Events to signal new registrations and trips.
    event TouristRegistered(uint256 indexed touristId, bytes32 offChainIdHash);
    event TripRegistered(uint256 indexed tripId, uint256 indexed touristId);

    constructor() {
        owner = msg.sender;
    }

    // Register a tourist: only the hash of the unique Postgres ID is stored on-chain.
    function registerTourist(
        bytes32 _offChainIdHash
    ) public returns (uint256) {
        require(msg.sender == owner, "Only the owner can register tourists.");
        require(_offChainIdHash != bytes32(0), "Invalid hash provided.");
        
        nextTouristId++;
        tourists[nextTouristId] = Tourist({
            offChainIdHash: _offChainIdHash,
            isRegistered: true
        });
        emit TouristRegistered(nextTouristId, _offChainIdHash);
        return nextTouristId;
    }
    
    // Register a trip: all trip data is stored on-chain, linked to the tourist ID.
    function registerTrip(
        uint256 _touristId,
        uint256 _startDate,
        uint256 _endDate,
        string memory _itinerary
    ) public returns (uint256) {
        require(msg.sender == owner, "Only the owner can register trips.");
        require(tourists[_touristId].isRegistered, "Tourist not registered.");
        require(_startDate > 0 && _endDate > 0, "Invalid dates provided.");
        require(_endDate >= _startDate, "End date must be after start date.");
        require(bytes(_itinerary).length > 0, "Itinerary cannot be empty.");
        
        nextTripId++;
        trips[nextTripId] = Trip({
            touristId: _touristId,
            startDate: _startDate,
            endDate: _endDate,
            itinerary: _itinerary
        });
        emit TripRegistered(nextTripId, _touristId);
        return nextTripId;
    }

    // A public view function to check if an ID has been registered.
    function isTouristRegistered(uint256 _touristId) public view returns (bool) {
        return tourists[_touristId].isRegistered;
    }
    
    // Get tourist details by ID
    function getTourist(uint256 _touristId) public view returns (bytes32, bool) {
        Tourist memory tourist = tourists[_touristId];
        return (tourist.offChainIdHash, tourist.isRegistered);
    }
    
    // Get trip details by ID
    function getTrip(uint256 _tripId) public view returns (uint256, uint256, uint256, string memory) {
        Trip memory trip = trips[_tripId];
        return (trip.touristId, trip.startDate, trip.endDate, trip.itinerary);
    }
}