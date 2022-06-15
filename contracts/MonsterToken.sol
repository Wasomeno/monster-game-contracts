// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import '@openzeppelin/contracts/access/Ownable.sol';

contract MonsterToken is ERC20,Ownable {
    constructor() ERC20("Monster", "MNST") {
        _mint(address (this), 100000000 * 10 ** 18);
    }

    function send(address _to, uint _amount) public onlyOwner {
        approve(address(this), _amount * 10 ** 18);
        transferFrom(address(this), _to, _amount * 10 ** 18);
    }

    function mint(address _to, uint _amount) public {
        _mint(_to, _amount * 10 ** 18);
    }

    
}