pragma solidity 0.5.16;

import { CompoundIntegration } from "../masset/platform-integrations/CompoundIntegration.sol";
import { AaveIntegration } from "../masset/platform-integrations/AaveIntegration.sol";
import { Masset } from "../masset/Masset.sol";
import { IBasketManager } from "../interfaces/IBasketManager.sol";

contract HarveySetup {

    constructor () payable public {
        address(0xAaaaAaAAaaaAAaAAaAaaaaAAAAAaAaaaAaAaaAA0).transfer(1000000000000000000);
        address(0xAaAaaAAAaAaaAaAaAaaAAaAaAAAAAaAAAaaAaAa2).transfer(1000000000000000000);
        address(0xafFEaFFEAFfeAfFEAffeaFfEAfFEaffeafFeAFfE).transfer(1000000000000000000);
    }

    function run(AaveIntegration _aaveIntegration, CompoundIntegration _compoundIntegration, address _mAsset, address _basketManager, address _basset_1, address _basset_2, address _basset_3, address _basset_4) public payable {
        _aaveIntegration.initializeGhostState(_mAsset, _basketManager);
        _compoundIntegration.initializeGhostState(_mAsset, _basketManager);
        Masset(_mAsset).enableChecking(_basset_1, _basset_2, _basset_3, _basset_4);
        IBasketManager(_basketManager).enableChecking(_basset_1, _basset_2, _basset_3, _basset_4);
    }
}