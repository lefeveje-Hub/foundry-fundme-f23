// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract addresses across chains
// Sepolia ETH/USD
// Mainnet ETH/USD


pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";
import {Vm} from "forge-std/Vm.sol";

contract HelperConfig {
    Vm public constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));

    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8; // 2000 USD

    struct NetworkConfig {
        address priceFeed; // Address of the price feed contract
    }

    constructor() {
        if (block.chainid == 11155111) { // Sepolia
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 31337) { // Anvil
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;

    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig; // If we already deployed the mock, return it
        }


        // 1. Deploy mocks when we are on a local anvil chain
        // 2. Keep track of contract addresses across chains
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockV3Aggregator)
        });
        return anvilConfig;
    }

    
    function getPriceFeed() public view returns (address) {
        return activeNetworkConfig.priceFeed;
    }
}