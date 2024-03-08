// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../contracts/Foldable.sol";

contract FoldableTest is Test {
    Foldable public foldable;

    function setUp() public {
        foldable = new Foldable();
    }

    // function testMessageOnDeployment() public view {
    //     require(
    //         keccak256(bytes(yourContract.greeting())) ==
    //             keccak256("Building Unstoppable Apps!!!")
    //     );
    // }

    // function testSetNewMessage() public {
    //     yourContract.setGreeting("Learn Scaffold-ETH 2! :)");
    //     require(
    //         keccak256(bytes(yourContract.greeting())) ==
    //             keccak256("Learn Scaffold-ETH 2! :)")
    //     );
    // }
    
}
