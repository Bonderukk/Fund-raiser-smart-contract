//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Fund Raiser Smart Contract
// People are allowed to deposit ETH and Owner (deployer of the contract)
// is able to to withdraw them.

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract FundMe {

    address public owner;
    uint256 minFundValue;
    uint256 userFundedAmount;
    mapping(address => uint256) public addressToFunded;
    address[] funders;

    constructor() {
        owner = msg.sender;
    }

    function fund() payable public {
        userFundedAmount = (getEthPrice() * msg.value) / (10**36);
        minFundValue = 10;
        require(userFundedAmount >= minFundValue, "You need to spend atleast 10 USD.");
        addressToFunded[msg.sender] += userFundedAmount;
        funders.push(msg.sender);

    }

    function getEthPrice() public view returns(uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (, int256 price,,,) = priceFeed.latestRoundData();
        // We pay ETH in Wei (18 Decimals), and price is returned with 8 decimals 
        // so we add remaining 10 Decimals for easier comparison later on
        return uint256(price* (10**10));

    }

    function withdraw() public {
        require(owner==msg.sender, "You need to be owner to withdraw funds");
        payable(msg.sender).transfer(address(this).balance);

        for(uint256 userIndex; userIndex < funders.length; userIndex++) {
            address funderAddress = funders[userIndex];
            addressToFunded[funderAddress] = 0;
        }
    }


}
