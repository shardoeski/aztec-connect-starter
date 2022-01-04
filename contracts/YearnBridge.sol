// SPDX-License-Identifier: GPL-2.0-only
// Copyright 2020 Spilsbury Holdings Ltd
pragma solidity >=0.6.6 <0.8.0;
pragma experimental ABIEncoderV2;

import { SafeMath } from "@openzeppelin/contracts/math/SafeMath.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { IDefiBridge } from "./interfaces/IDefiBridge.sol";
import { Types } from "./Types.sol";

interface VaultAPI {
    function deposit(uint256 amount, address recipient) external returns (uint256);
    function withdraw(uint256 maxShares, address recipient) external returns (uint256);
}

contract YearnBridge is IDefiBridge {
  using SafeMath for uint256;

  address public immutable rollupProcessor;

  constructor(address _rollupProcessor, address _vaultAddress) public {
    rollupProcessor = _rollupProcessor;
  }

  receive() external payable {}

  function convert(
    Types.AztecAsset calldata inputAssetA,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata outputAssetA,
    Types.AztecAsset calldata,
    uint256 inputValue,
    uint256,
    uint64
  )
    external
    payable
    override
    returns (
      uint256 outputValueA,
      uint256,
      bool isAsync
    )
  {
    require(
            msg.sender == rollupProcessor,
            "YearnBrdige: INVALID_CALLER"
        );

    isAsync = false;

   string memory inputAssetName =  IERC20(inputAssetA.erc20Address).name();
   string memory outputAssetName =   IERC20(outputAssetA.erc20Address).name();

   // Deposit
   if(isVault(inputAssetName)){
        vault = VaultAPI(outputAssetA.erc20Address);
        uint256 outputValueA = vault.deposit(inputValue, rollupProcessor);
   } 
   // Withdraw 
   else if (isVault(outputAssetName)){
        vault = VaultAPI(inputAssetA.erc20Address);
        uint outputValueA = vault.withdraw(inputValue, rollupProcessor);
   } 

   else {
        revert("YearnBridge: The input or output asset has to be a yearn Vault");
   }

   function isVault(string str) internal  pure returns (string) {
      bytes memory strBytes = bytes(str);
      bytes memory result = new bytes(2);
      result[0] = strBytes[0];
      result[1] = strBytes[1];
      string subString = string(result);

      if(subString == "yv"){
          return true;
      } else{
          return false;
      }
  }



  function canFinalise(
    uint256 /*interactionNonce*/
  ) external view override returns (bool) {
    return false;
  }

  function finalise(
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    Types.AztecAsset calldata,
    uint256,
    uint64
  ) external payable override returns (uint256, uint256) {
    require(false);
  }
}
