// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {RateLimiter} from "@ccip/contracts/src/v0.8/ccip/libraries/RateLimiter.sol";
import {TokenPool} from "@ccip/contracts/src/v0.8/ccip/pools/TokenPool.sol";

contract ConfigurePoolScript is Script{
    function run(address localPool, uint64 remoteChainSelector, address remotePool, address remoteToken, bool outboundRateLimiterIsEnabled, uint128 outboundRateLimiterCapacity, uint128 outboundRateLimiterRate) public{
        vm.startBroadcast();
        bytes[] memory remotePoolAddress = new bytes[](1);
        remotePoolAddress[0] = abi.encode(remotePool);
        TokenPool.ChainUpdate[] memory chainsToAdd = new TokenPool.ChainUpdate[](1);
        chainsToAdd[0] = TokenPool.ChainUpdate({
            remoteChainSelector: remoteChainSelector,
            remotePoolAddress: remotePoolAddress,
            remoteTokenAddress: abi.encode(remoteToken),
            inboundRateLimiterConfig: RateLimiter.Config({
                isEnabled: inboundRateLimiterIsEnabled,
                capacity: inboundRateLimiterCapacity,
                rate: inboundRateLimiterRate
            })
        });
        TokenPool(localPool).applyChainUpdates(chainsToAdd);
    }

}