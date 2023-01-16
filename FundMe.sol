// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./PriceConverter.sol";

// 9,62,874 - non-constant
// 9,39,894 - constant

error NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5 * 1e18; // 1 * 10 ** 18
    // 23515 - non-constant
    // 21415 - constant
    //  23515 * 27000000000 = 634,905,000,000,000 = $ 0.983086902 - NOT using Constant
    // 21415 * 27000000000 = 578,205,000,000,000 =  $ 0.89506134  - using Constant
    //                                difference = $ 0.088025562

    address[] public funders;
    mapping(address => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    // 21,508 gas - Immutable
    // 23,644 gas - Without Immutable

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate() >= MINIMUM_USD,
            "Didn't Send Enough"
        );
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = msg.value;
    }

    function withdraw() public OnlyOwner {
        // Reset or Empty the Mapping
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        // Reset the array
        funders = new address[](0);

        // Actually withdraw the funds.
        // Transfer
        // msg.sender = address
        // payable(msg.sender) = payable address
        // payable(msg.sender).transfer(address(this).balance);

        // Send
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess,"Send Failed");

        // Call
        // (bool callSuccess, bytes memory dataReturned ) = payable(msg.sender).call{value:address(this).balance}("");
        (bool callSuccess, ) = payable(msg.sender).call{
            value: address(this).balance
        }("");
        require(callSuccess, "Call Failed");
    }

    modifier OnlyOwner() {
        // require(msg.sender == i_owner,"Sender is not Owner!");
        if (msg.sender != i_owner) {
            revert NotOwner();
        } // Very Much Gas Efficient
        _;
    }

    // What happens if someone sends this Contract ETH without calling the fund Function.

    // receive ();
    // fallback();
}
