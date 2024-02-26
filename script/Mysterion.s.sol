// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console2} from "forge-std/Script.sol";
import {Mysterion} from "../src/Mysterion.sol";

contract MysterionScript is Script {
    function setUp() public {}

    function run() public {
        address deployer = vm.envAddress(("DEPLOYER"));
        uint256 deployerPrivateKey = vm.envUint(("PRIVATE_KEY"));
        vm.startBroadcast(deployerPrivateKey);
        // default address

        Mysterion erc721 = new Mysterion(deployer);
        vm.stopBroadcast();
    }
}
