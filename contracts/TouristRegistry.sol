// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// This contract serves as a tamper-proof registry for tourist IDs.
// Only an authorized "owner" (your backend) can register new tourists.
contract TouristRegistry {
    // The address of the authorized official who can register tourists.
    address public owner;

    // A data structure to hold a tourist's information.
    // We store a hash of sensitive data for privacy and an ID for easy lookup.
    struct Tourist {
        string name;
        string nationality;
        bytes32 documentHash; // A secure hash of the passport/Aadhaar number
        uint256 tripEndTimestamp;
        bool isVerified;
    }

    // A mapping to store our Tourist data, indexed by a unique ID.
    mapping(uint256 => Tourist) public tourists;
    uint256 public nextTouristId;

    // An event to signal that a new tourist has been registered.
    // This allows our backend to listen for new registrations and get the new ID.
    event TouristRegistered(uint256 touristId, address indexed verifier);

    // The constructor sets the owner of the contract to the address that deploys it.
    constructor() {
        owner = msg.sender;
    }

    // Function to register a new tourist.
    // The onlyOwner modifier ensures that only the backend can call this function.
    function registerTourist(
        string memory _name,
        string memory _nationality,
        bytes32 _documentHash,
        uint256 _tripEndTimestamp
    ) public {
        require(msg.sender == owner, "Only the owner can register tourists.");

        nextTouristId++;

        tourists[nextTouristId] = Tourist({
            name: _name,
            nationality: _nationality,
            documentHash: _documentHash,
            tripEndTimestamp: _tripEndTimestamp,
            isVerified: true
        });

        emit TouristRegistered(nextTouristId, msg.sender);
    }
}
