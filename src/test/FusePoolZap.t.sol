// SPDX-License-Identifier: Unlicense
pragma solidity >=0.8.0;

import {DSTest} from "ds-test/test.sol";
import {Utilities} from "./utils/Utilities.sol";
import {console} from "./utils/Console.sol";
import {Vm} from "forge-std/Vm.sol";
import {ERC20} from "solmate/tokens/ERC20.sol";
import {IFusePool, IFToken, FusePoolZap} from "../FusePoolZap.sol";

contract FusePoolZapTest is DSTest {
    Vm internal immutable vm = Vm(HEVM_ADDRESS);
    FusePoolZap internal zap;

    address internal constant TRIBE_FUSE_POOL =
        0x07cd53380FE9B2a5E64099591b498c73F0EfaA66;
    address internal constant FRAX3CRV =
        0xd632f22692FaC7611d2AA1C0D552930D43CAEd3B;
    address internal constant FTOKEN =
        0x2ec70d3Ff3FD7ac5c2a72AAA64A398b6CA7428A5;
    address internal constant FETHER =
        0xe92a3db67e4b6AC86114149F522644b34264f858;
    address internal constant DEPOSITOR =
        0x47Bc10781E8f71c0e7cf97B0a5a88F4CFfF21309;

    Utilities internal utils;
    address payable[] internal users;

    //
    function setUp() public {
        utils = new Utilities();
        users = utils.createUsers(5);
        zap = new FusePoolZap();
    }

    function testCanZapIn() public {
        vm.startPrank(DEPOSITOR);

        uint256 amount = 1000 * 10**ERC20(FRAX3CRV).decimals();

        ERC20(FRAX3CRV).approve(address(zap), amount);
        zap.zapIn(TRIBE_FUSE_POOL, FRAX3CRV, amount);

        // Should get 5000 fTokens back
        assertEq(
            ERC20(FTOKEN).balanceOf(DEPOSITOR),
            5000 * 10**ERC20(FTOKEN).decimals()
        );

        vm.stopPrank();
    }

    function testCanZapInWithEth() public {
        vm.startPrank(DEPOSITOR);

        uint256 amount = 0.01 ether;

        zap.zapIn{value: amount}(TRIBE_FUSE_POOL, address(0), amount);

        // Should get 0.05 fETHER back
        assertEq(ERC20(FETHER).balanceOf(DEPOSITOR), 0.05 ether);

        vm.stopPrank();
    }
}
