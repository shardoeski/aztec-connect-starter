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

  VaultAPI public vault;

  address public constant YFI = address(0x0bc529c00c6401aef6d220be8c6ea1667f6ad93e);

  address public constant yvYFI = address(0xE14d13d8B3b85aF791b2AADD661cDBd5E6097Db1);


  constructor(address _rollupProcessor, address _vaultAddress) public {
    rollupProcessor = _rollupProcessor;
    vault = VaultAPI(_vaultAddress);
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
    
    if (inputAssetA.erc20Address == YFI) {
        uint256 outputValueA = vault.deposit(inputValue, rollupProcessor);
    } 
    
    if(inputAssetA.erc20Address == yvYFI){
        require(
            outputAssetA.assetType == Types.AztecAsset.ETH,
            "YearnBridge: Only ETH acceptable as a withdrawable asset"
        );
        uint256 outputValueA = vault.withdraw(inputValue, rollupProcessor);
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
