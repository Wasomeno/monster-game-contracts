// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";


contract Items is ERC1155 {
    uint public constant BERRY = 0;
    uint public constant GOLD = 1;
    uint public constant HUNGER_POTION = 2;

    mapping(uint => uint[]) public itemRateSet;
    mapping(uint => uint[]) public itemSet;

    constructor() ERC1155("") {

    }

    function newItemRatesSet(uint _id, uint[] memory _rate) public {
        for(uint i ; i < _rate.length ; i++) {
            itemRateSet[_id].push(_rate[i]);   
        }
    }

    function newItemsSet(uint _id, uint[] memory _item) public {
        for(uint i ; i < _item.length ; i++) {
            itemSet[_id].push(_item[i]);   
        }
    }

    function beginnerMissionReward(address _user, uint _odds) public {
        if(_odds <= 60 && 0 <= _odds) {
            _mintBatch(_user, itemSet[0], itemRateSet[0],"");
        } else if(_odds <= 90 && 70 <= _odds ) {
            _mintBatch(_user, itemSet[1], itemRateSet[1],"");
        } else {
            _mintBatch(_user, itemSet[2], itemRateSet[2],"");
        }
    }

    function intermediateMissionReward(address _user, uint _odds) public {
        if(_odds <= 60 && 0 <= _odds) {
            _mintBatch(_user, itemSet[3], itemRateSet[3],"");
        } else if(_odds <= 90 && 70 <= _odds ) {
            _mintBatch(_user, itemSet[4], itemRateSet[4],"");
        } else {
            _mintBatch(_user, itemSet[5], itemRateSet[5],"");
        }
    }
}