// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "./IMonsterGame.sol";

contract Items is ERC1155 {

    IMonsterGame gameInterface;

    uint public constant M_COINS = 0;
    uint public constant BERRY = 1;
    uint public constant HUNGER_POTION = 2;
    uint public constant EXP_BOTTLE = 3;
    uint public constant TOKEN_CRYSTAL = 4;


    mapping(uint => uint[]) public itemRateSet;
    mapping(uint => uint[]) public itemSet;
    mapping(uint => uint[]) public bossRewardSet;
    mapping(uint => uint[]) public bossRateSet;

    constructor(address monsterGame) ERC1155("") {
        gameInterface = IMonsterGame(monsterGame);

        itemSet[0].push(0);
        itemSet[0].push(1);
        itemRateSet[0].push(3);
        itemRateSet[0].push(5);

        itemSet[1].push(0);
        itemSet[1].push(1);
        itemRateSet[1].push(6);
        itemRateSet[1].push(7);

        itemSet[2].push(0);
        itemSet[2].push(1);
        itemRateSet[2].push(10);
        itemRateSet[2].push(10);

        bossRewardSet[0].push(0);
        bossRewardSet[0].push(2);
        bossRewardSet[0].push(3);
        bossRewardSet[0].push(4);

        bossRewardSet[1].push(0);
        bossRewardSet[1].push(2);
        bossRewardSet[1].push(4);

        bossRateSet[1].push(10);
        bossRateSet[1].push(1);
        bossRateSet[1].push(3);

        bossRateSet[0].push(50);
        bossRateSet[0].push(2);
        bossRateSet[0].push(1);
        bossRateSet[0].push(10);
        

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
            gameInterface.checkItemOnInventory(itemSet[0], itemRateSet[0], _user);
        } else if(_odds <= 90 && 70 <= _odds ) {
            _mintBatch(_user, itemSet[1], itemRateSet[1],"");
            gameInterface.checkItemOnInventory(itemSet[1], itemRateSet[1], _user);
        } else {
            _mintBatch(_user, itemSet[2], itemRateSet[2],"");
            gameInterface.checkItemOnInventory(itemSet[2], itemRateSet[2], _user);
        }
    }

    function intermediateMissionReward(address _user, uint _odds) public {
        if(_odds <= 60 && 0 <= _odds) {
            _mintBatch(_user, itemSet[3], itemRateSet[3],"");
            gameInterface.checkItemOnInventory(itemSet[3], itemRateSet[3], _user);
        } else if(_odds <= 90 && 70 <= _odds ) {
            _mintBatch(_user, itemSet[4], itemRateSet[4],"");
            gameInterface.checkItemOnInventory(itemSet[4], itemRateSet[4], _user);
        } else {
            _mintBatch(_user, itemSet[5], itemRateSet[5],"");
            gameInterface.checkItemOnInventory(itemSet[5], itemRateSet[5], _user);
        }
    }

    function bossFightReward(address _user, uint _odds, uint _chance) public {
        if(_odds < _chance) {
            _mintBatch(_user, bossRewardSet[0], bossRateSet[0],"");
            gameInterface.checkItemOnInventory(bossRewardSet[0], bossRateSet[0], _user);
        } else {
            _mintBatch(_user, bossRewardSet[1], bossRateSet[1],"");
            gameInterface.checkItemOnInventory(bossRewardSet[1], bossRateSet[1], _user);
        }
    }
}