import { ethers } from "ethers";

// Environment variables for blockchain interaction
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = process.env.RPC_URL;
const TOURIST_REGISTRY_ADDRESS = process.env.TOURIST_REGISTRY_ADDRESS;

// TouristRegistry contract ABI
const TOURIST_REGISTRY_ABI = [
  "function registerTourist(bytes32 _offChainIdHash) public returns (uint256)",
  "function registerTrip(uint256 _touristId, uint256 _startDate, uint256 _endDate, string memory _itinerary) public returns (uint256)",
  "function isTouristRegistered(uint256 _touristId) public view returns (bool)",
  "function getTourist(uint256 _touristId) public view returns (bytes32, bool)",
  "function getTrip(uint256 _tripId) public view returns (uint256, uint256, uint256, string)",
  "function getTouristIdByHash(bytes32 _offChainIdHash) public view returns (uint256)",
  "function getTouristTripIds(uint256 _touristId) public view returns (uint256[])",
  "function getTouristTripCount(uint256 _touristId) public view returns (uint256)",
  "function getMultipleTrips(uint256[] _tripIds) public view returns (uint256[], uint256[], uint256[], string[])",
  "function getTotalCounts() public view returns (uint256, uint256)"
];

class BlockchainService {
  constructor() {
    this.provider = null;
    this.wallet = null;
    this.contract = null;
    this.isEnabled = false;
    
    this.initialize();
  }

  initialize() {
    try {
      // Check if blockchain config is available
      if (!PRIVATE_KEY || !RPC_URL || !TOURIST_REGISTRY_ADDRESS) {
        console.warn('⚠️  Blockchain configuration missing. Blockchain features disabled.');
        return;
      }

      this.provider = new ethers.JsonRpcProvider(RPC_URL);
      this.wallet = new ethers.Wallet(PRIVATE_KEY, this.provider);
      this.contract = new ethers.Contract(TOURIST_REGISTRY_ADDRESS, TOURIST_REGISTRY_ABI, this.wallet);
      this.isEnabled = true;
      
      console.log('✅ Blockchain service initialized successfully');
    } catch (error) {
      console.error('❌ Failed to initialize blockchain service:', error.message);
      this.isEnabled = false;
    }
  }

  // Check if blockchain is available
  isBlockchainEnabled() {
    return this.isEnabled;
  }

  // Hash user ID for blockchain storage
  hashUserId(userId) {
    return ethers.keccak256(ethers.toUtf8Bytes(userId));
  }

  // Register tourist on blockchain
  async registerTourist(userId) {
    if (!this.isEnabled) {
      throw new Error('Blockchain service not available');
    }

    try {
      const hashedUserId = this.hashUserId(userId);
      
      // Check if already registered
      const existingTouristId = await this.contract.getTouristIdByHash(hashedUserId);
      if (existingTouristId.toString() !== '0') {
        return {
          blockchainTouristId: existingTouristId.toString(),
          transactionHash: null,
          alreadyRegistered: true
        };
      }

      const tx = await this.contract.registerTourist(hashedUserId);
      const receipt = await tx.wait();

      // Extract tourist ID from transaction logs
      const touristRegisteredEvent = receipt.logs.find(
        log => log.fragment && log.fragment.name === 'TouristRegistered'
      );
      
      const blockchainTouristId = touristRegisteredEvent ? 
        touristRegisteredEvent.args[0].toString() : null;

      return {
        blockchainTouristId,
        transactionHash: receipt.hash,
        alreadyRegistered: false
      };
    } catch (error) {
      console.error('Error registering tourist on blockchain:', error);
      throw error;
    }
  }

  // Register trip on blockchain
  async registerTrip(userId, startDate, endDate, itinerary) {
    if (!this.isEnabled) {
      throw new Error('Blockchain service not available');
    }

    try {
      const hashedUserId = this.hashUserId(userId);
      const blockchainTouristId = await this.contract.getTouristIdByHash(hashedUserId);

      if (blockchainTouristId.toString() === '0') {
        throw new Error('User not registered on blockchain');
      }

      const startTimestamp = Math.floor(new Date(startDate).getTime() / 1000);
      const endTimestamp = Math.floor(new Date(endDate).getTime() / 1000);
      const itineraryString = typeof itinerary === 'object' ? 
        JSON.stringify(itinerary) : itinerary.toString();

      const tx = await this.contract.registerTrip(
        blockchainTouristId,
        startTimestamp,
        endTimestamp,
        itineraryString
      );
      const receipt = await tx.wait();

      // Extract trip ID from transaction logs
      const tripRegisteredEvent = receipt.logs.find(
        log => log.fragment && log.fragment.name === 'TripRegistered'
      );
      
      const blockchainTripId = tripRegisteredEvent ? 
        tripRegisteredEvent.args[0].toString() : null;

      return {
        blockchainTripId,
        blockchainTouristId: blockchainTouristId.toString(),
        transactionHash: receipt.hash
      };
    } catch (error) {
      console.error('Error registering trip on blockchain:', error);
      throw error;
    }
  }

  // Get tourist blockchain data
  async getTouristBlockchainData(userId) {
    if (!this.isEnabled) {
      return {
        isRegistered: false,
        touristId: '0',
        tripCount: 0,
        trips: []
      };
    }

    try {
      const hashedUserId = this.hashUserId(userId);
      const blockchainTouristId = await this.contract.getTouristIdByHash(hashedUserId);
      const isRegistered = blockchainTouristId.toString() !== '0';
      
      let trips = [];
      let tripCount = 0;
      
      if (isRegistered) {
        const tripIds = await this.contract.getTouristTripIds(blockchainTouristId);
        tripCount = tripIds.length;
        
        if (tripIds.length > 0) {
          const [touristIds, startDates, endDates, itineraries] = 
            await this.contract.getMultipleTrips(tripIds);
          
          trips = tripIds.map((tripId, index) => ({
            blockchainTripId: tripId.toString(),
            touristId: touristIds[index].toString(),
            startDate: new Date(Number(startDates[index]) * 1000),
            endDate: new Date(Number(endDates[index]) * 1000),
            itinerary: itineraries[index]
          }));
        }
      }

      return {
        isRegistered,
        touristId: blockchainTouristId.toString(),
        tripCount,
        trips
      };
    } catch (error) {
      console.error('Error getting tourist blockchain data:', error);
      return {
        isRegistered: false,
        touristId: '0',
        tripCount: 0,
        trips: []
      };
    }
  }

  // Get contract stats
  async getContractStats() {
    if (!this.isEnabled) {
      return { totalTourists: 0, totalTrips: 0 };
    }

    try {
      const [totalTourists, totalTrips] = await this.contract.getTotalCounts();
      return {
        totalTourists: totalTourists.toString(),
        totalTrips: totalTrips.toString()
      };
    } catch (error) {
      console.error('Error getting contract stats:', error);
      return { totalTourists: 0, totalTrips: 0 };
    }
  }

  // Verify trip on blockchain
  async verifyTrip(userId, tripId = null) {
    if (!this.isEnabled) {
      return { isVerified: false, tripIds: [] };
    }

    try {
      const hashedUserId = this.hashUserId(userId);
      const blockchainTouristId = await this.contract.getTouristIdByHash(hashedUserId);
      
      if (blockchainTouristId.toString() === '0') {
        return { isVerified: false, tripIds: [] };
      }

      const blockchainTripIds = await this.contract.getTouristTripIds(blockchainTouristId);
      const isVerified = blockchainTripIds.length > 0;

      return {
        isVerified,
        touristId: blockchainTouristId.toString(),
        tripIds: blockchainTripIds.map(id => id.toString())
      };
    } catch (error) {
      console.error('Error verifying trip:', error);
      return { isVerified: false, tripIds: [] };
    }
  }
}

// Create singleton instance
const blockchainService = new BlockchainService();

export default blockchainService;
