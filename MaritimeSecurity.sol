// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MaritimeSecurity {
    struct Vehicle {
        string vehicleID;
        bool isAuthorized;
        uint256 lastAccessTime;
        address registeredBy;
        uint256 historyCount;
    }

    mapping(string => Vehicle) public vehicles;
    mapping(string => uint256[]) public vehicleAccessHistory;

    address public owner;

    event VehicleRegistered(string vehicleID, address registeredBy);
    event VehicleAccessUpdated(string vehicleID, bool isAuthorized);
    event AccessLogged(string vehicleID, uint256 timestamp);
    event VehicleAccessRevoked(string vehicleID);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function registerVehicle(string memory _vehicleID) public onlyOwner {
        require(vehicles[_vehicleID].registeredBy == address(0), "Vehicle already registered.");
        vehicles[_vehicleID] = Vehicle(_vehicleID, true, 0, msg.sender, 0);
        emit VehicleRegistered(_vehicleID, msg.sender);
    }

    function authenticateVehicle(string memory _vehicleID) public view returns (bool) {
        require(vehicles[_vehicleID].registeredBy != address(0), "Vehicle not registered.");
        return vehicles[_vehicleID].isAuthorized;
    }

    function logAccess(string memory _vehicleID) public {
        require(vehicles[_vehicleID].isAuthorized, "Unauthorized vehicle.");
        vehicles[_vehicleID].lastAccessTime = block.timestamp;
        vehicles[_vehicleID].historyCount += 1;
        vehicleAccessHistory[_vehicleID].push(block.timestamp);
        emit AccessLogged(_vehicleID, block.timestamp);
    }

    function updateVehicleStatus(string memory _vehicleID, bool _isAuthorized) public onlyOwner {
        require(vehicles[_vehicleID].registeredBy != address(0), "Vehicle not registered.");
        vehicles[_vehicleID].isAuthorized = _isAuthorized;
        emit VehicleAccessUpdated(_vehicleID, _isAuthorized);
    }

    function revokeVehicleAccess(string memory _vehicleID) public onlyOwner {
        require(vehicles[_vehicleID].isAuthorized, "Vehicle already revoked.");
        vehicles[_vehicleID].isAuthorized = false;
        emit VehicleAccessRevoked(_vehicleID);
    }

    function checkVehicleHistory(string memory _vehicleID) public view returns (uint256[] memory) {
        return vehicleAccessHistory[_vehicleID];
    }
}
