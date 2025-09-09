import { ethers } from "ethers";

// Environment variables for blockchain interaction
const PRIVATE_KEY = process.env.PRIVATE_KEY;
const RPC_URL = process.env.RPC_URL;
const TOURIST_REGISTRY_ADDRESS = process.env.TOURIST_REGISTRY_ADDRESS;

// TouristRegistry contract ABI - Updated with actual deployed contract
const TOURIST_REGISTRY_ABI = [
  {
    "inputs": [],
    "name": "owner",
    "outputs": [
      {
        "internalType": "address",
        "name": "",
        "type": "address"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "bytes32",
        "name": "_offChainIdHash",
        "type": "bytes32"
      }
    ],
    "name": "registerTourist",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_touristId",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_startDate",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "_endDate",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "_itinerary",
        "type": "string"
      }
    ],
    "name": "registerTrip",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      }
    ],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_touristId",
        "type": "uint256"
      }
    ],
    "name": "isTouristRegistered",
    "outputs": [
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_touristId",
        "type": "uint256"
      }
    ],
    "name": "getTourist",
    "outputs": [
      {
        "internalType": "bytes32",
        "name": "",
        "type": "bytes32"
      },
      {
        "internalType": "bool",
        "name": "",
        "type": "bool"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "inputs": [
      {
        "internalType": "uint256",
        "name": "_tripId",
        "type": "uint256"
      }
    ],
    "name": "getTrip",
    "outputs": [
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "uint256",
        "name": "",
        "type": "uint256"
      },
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "touristId",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "bytes32",
        "name": "offChainIdHash",
        "type": "bytes32"
      }
    ],
    "name": "TouristRegistered",
    "type": "event"
  },
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "tripId",
        "type": "uint256"
      },
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "touristId",
        "type": "uint256"
      }
    ],
    "name": "TripRegistered",
    "type": "event"
  }
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
      
      console.log(`Registering tourist with hash: ${hashedUserId}`);
      
      const tx = await this.contract.registerTourist(hashedUserId);
      console.log(`Transaction sent: ${tx.hash}`);
      
      const receipt = await tx.wait();
      console.log(`Transaction confirmed in block: ${receipt.blockNumber}`);

      // Extract tourist ID from transaction logs
      let blockchainTouristId = null;
      
      for (const log of receipt.logs) {
        try {
          const parsedLog = this.contract.interface.parseLog(log);
          if (parsedLog && parsedLog.name === 'TouristRegistered') {
            blockchainTouristId = parsedLog.args[0].toString();
            break;
          }
        } catch (e) {
          // Skip unparseable logs
        }
      }

      return {
        touristId: blockchainTouristId,
        transactionHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString()
      };
    } catch (error) {
      console.error('Error registering tourist on blockchain:', error);
      throw error;
    }
  }

  // Register trip on blockchain
  async registerTrip(blockchainTouristId, startDate, endDate, itinerary) {
    if (!this.isEnabled) {
      throw new Error('Blockchain service not available');
    }

    try {
      // Validate tourist is registered
      const isRegistered = await this.contract.isTouristRegistered(blockchainTouristId);
      if (!isRegistered) {
        throw new Error('Tourist not registered on blockchain');
      }

      const startTimestamp = Math.floor(new Date(startDate).getTime() / 1000);
      const endTimestamp = Math.floor(new Date(endDate).getTime() / 1000);
      const itineraryString = typeof itinerary === 'object' ? 
        JSON.stringify(itinerary) : itinerary.toString();

      console.log(`Registering trip for tourist ${blockchainTouristId}`);
      
      const tx = await this.contract.registerTrip(
        blockchainTouristId,
        startTimestamp,
        endTimestamp,
        itineraryString
      );
      console.log(`Trip transaction sent: ${tx.hash}`);
      
      const receipt = await tx.wait();
      console.log(`Trip transaction confirmed in block: ${receipt.blockNumber}`);

      // Extract trip ID from transaction logs
      let blockchainTripId = null;
      
      for (const log of receipt.logs) {
        try {
          const parsedLog = this.contract.interface.parseLog(log);
          if (parsedLog && parsedLog.name === 'TripRegistered') {
            blockchainTripId = parsedLog.args[0].toString();
            break;
          }
        } catch (e) {
          // Skip unparseable logs
        }
      }

      return {
        tripId: blockchainTripId,
        touristId: blockchainTouristId.toString(),
        transactionHash: receipt.hash,
        blockNumber: receipt.blockNumber,
        gasUsed: receipt.gasUsed.toString()
      };
    } catch (error) {
      console.error('Error registering trip on blockchain:', error);
      throw error;
    }
  }

  // Get tourist blockchain data
  async getTouristBlockchainData(blockchainTouristId) {
    if (!this.isEnabled) {
      return {
        isRegistered: false,
        touristId: '0',
        offChainIdHash: ''
      };
    }

    try {
      const isRegistered = await this.contract.isTouristRegistered(blockchainTouristId);
      
      if (!isRegistered) {
        return {
          isRegistered: false,
          touristId: blockchainTouristId.toString(),
          offChainIdHash: ''
        };
      }

      const [offChainIdHash, registered] = await this.contract.getTourist(blockchainTouristId);

      return {
        isRegistered: registered,
        touristId: blockchainTouristId.toString(),
        offChainIdHash: offChainIdHash
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

  // Get trip data from blockchain
  async getTripBlockchainData(tripId) {
    if (!this.isEnabled) {
      return null;
    }

    try {
      const [touristId, startDate, endDate, itinerary] = await this.contract.getTrip(tripId);
      
      return {
        tripId: tripId.toString(),
        touristId: touristId.toString(),
        startDate: new Date(Number(startDate) * 1000),
        endDate: new Date(Number(endDate) * 1000),
        itinerary: itinerary
      };
    } catch (error) {
      console.error('Error getting trip blockchain data:', error);
      return null;
    }
  }

  // Verify trip exists on blockchain
  async verifyTrip(tripId) {
    if (!this.isEnabled) {
      return { isValid: false };
    }

    try {
      const tripData = await this.getTripBlockchainData(tripId);
      
      return {
        isValid: tripData !== null,
        tripData: tripData
      };
    } catch (error) {
      console.error('Error verifying trip:', error);
      return { isValid: false };
    }
  }

  // Get blockchain statistics (simplified version)
  async getBlockchainStats() {
    if (!this.isEnabled) {
      return { 
        totalTourists: '0', 
        totalTrips: '0',
        contractAddress: TOURIST_REGISTRY_ADDRESS 
      };
    }

    try {
      // Since your contract doesn't have getTotalCounts, we'll return basic info
      const owner = await this.contract.owner();
      
      return {
        totalTourists: 'N/A', // Would need to track this separately
        totalTrips: 'N/A',    // Would need to track this separately
        contractAddress: TOURIST_REGISTRY_ADDRESS,
        contractOwner: owner,
        isConnected: true
      };
    } catch (error) {
      console.error('Error getting blockchain stats:', error);
      return { 
        totalTourists: '0', 
        totalTrips: '0',
        contractAddress: TOURIST_REGISTRY_ADDRESS,
        isConnected: false
      };
    }
  }
}

// Create singleton instance
const blockchainService = new BlockchainService();

export default blockchainService;
