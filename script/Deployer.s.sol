// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {CCIPLocalSimulatorFork, Register} from "@chainlink-local/src/ccip/CCIPLocalSimulatorFork.sol";
import {IERC20} from "@ccip/contracts/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {RegistryModuleOwnerCustom} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/RegistryModuleOwnerCustom.sol";
import {TokenAdminRegistry} from "@ccip/contracts/src/v0.8/ccip/tokenAdminRegistry/TokenAdminRegistry.sol";
import {IRebaseToken} from "./src/interfaces/IRebaseToken.sol";
import {Script} from "forge-std/Script.sol";
import {Vault} from "./src/Vault.sol";

contract TokenAndPoolDeployer is Script{
    function run() public returns (RebaseToken token, RebaseTokenPool pool){
      CCIPLocalSimulatorFork ccipLocalSimulatorFork = new CCIPLocalSimulatorFork();
      Register.NetworkDetails networkDetails = ccipLocalSimulatorFork.getNetworkDetails(block.chainid);
      vm.startBroadcast();
      token = new RebaseToken();
      pool = new RebaseTokenPool(
          IERC20(address(token)),
          new address[](0),
          networkDetails.rmnProxyAddress,
          networkDetails.routerAddress
      );
      token.grantBurnAndMintRole(address(pool));
      RegistryModuleOwnerCustom(networkDetails.registryModuleOwnerCustomAddress).registerAdminViaOwner(address(token));
      tokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).acceptAdminRole(address(token));
      tokenAdminRegistry(networkDetails.tokenAdminRegistryAddress).setPool(address(token), address(pool));  
        vm.stopBroadcast();
    }
}

contract VaultDeployer is Script{
    function run(address _rebaseToken) public{
        vm.startBroadcast();
        vault = new Vault(IRebaseToken(_rebaseToken));
        IRebaseToken(_rebaseToken).grantBurnAndMintRole(address(vault));
        vm.stopBroadcast();
    }
}