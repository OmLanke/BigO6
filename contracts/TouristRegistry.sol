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
    mapping(bytes32 => uint256) public hashToTouristId; // Find tourist ID by hash
    mapping(uint256 => uint256[]) public touristTrips; // Tourist ID -> Trip IDs array
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
        require(hashToTouristId[_offChainIdHash] == 0, "Tourist already registered.");
        
        nextTouristId++;
        tourists[nextTouristId] = Tourist({
            offChainIdHash: _offChainIdHash,
            isRegistered: true
        });
        hashToTouristId[_offChainIdHash] = nextTouristId;
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
        touristTrips[_touristId].push(nextTripId);
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
    
    // Find tourist ID by their off-chain hash (useful for Flutter apps)
    function getTouristIdByHash(bytes32 _offChainIdHash) public view returns (uint256) {
        return hashToTouristId[_offChainIdHash];
    }
    
    // Get all trip IDs for a tourist
    function getTouristTripIds(uint256 _touristId) public view returns (uint256[] memory) {
        return touristTrips[_touristId];
    }
    
    // Get tourist trip count
    function getTouristTripCount(uint256 _touristId) public view returns (uint256) {
        return touristTrips[_touristId].length;
    }
    
    // Get multiple trips at once (gas efficient for mobile apps)
    function getMultipleTrips(uint256[] memory _tripIds) public view returns (
        uint256[] memory touristIds,
        uint256[] memory startDates,
        uint256[] memory endDates,
        string[] memory itineraries
    ) {
        uint256 length = _tripIds.length;
        touristIds = new uint256[](length);
        startDates = new uint256[](length);
        endDates = new uint256[](length);
        itineraries = new string[](length);
        
        for (uint256 i = 0; i < length; i++) {
            Trip memory trip = trips[_tripIds[i]];
            touristIds[i] = trip.touristId;
            startDates[i] = trip.startDate;
            endDates[i] = trip.endDate;  
            itineraries[i] = trip.itinerary;
        }
    }
    
    // Get total counts (useful for Flutter pagination)
    function getTotalCounts() public view returns (uint256 totalTourists, uint256 totalTrips) {
        return (nextTouristId, nextTripId);
    }
}