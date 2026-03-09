// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";

import {LiquidLensHTMLExample} from "../src/examples/LiquidLensHTMLExample.sol";
import {LiquidLensMintable721SVGExample} from "../src/examples/LiquidLensMintable721SVGExample.sol";
import {ILiquidBase} from "../src/interfaces/ILiquidBase.sol";
import {MockLiquid} from "../src/mocks/MockLiquid.sol";

contract LiquidLensExamplesTest is Test {
    address internal creator = makeAddr("creator");
    address internal collector = makeAddr("collector");

    MockLiquid internal liquid;
    LiquidLensHTMLExample internal lensHtml;
    LiquidLensMintable721SVGExample internal lensMintable721;

    function setUp() external {
        vm.prank(creator);
        liquid = new MockLiquid();
        liquid.setCreator(creator);

        lensHtml = new LiquidLensHTMLExample(
            address(liquid),
            "Liquid Lens HTML Example",
            "Single artwork Liquid lens example using HTML metadata.",
            "https://example.com/lens-html"
        );

        lensMintable721 = new LiquidLensMintable721SVGExample(
            address(liquid),
            "Liquid Lens Mintable 721 SVG Example",
            "LL721",
            "Mintable ERC721 Liquid lens example using SVG metadata.",
            "https://example.com/lens-721",
            10
        );
    }

    function test_LensHtmlReturnsJsonDataUri() external view {
        assertTrue(
            _startsWith(lensHtml.tokenURI(), "data:application/json;base64,")
        );
    }

    function test_LensHtmlChangesWithMarketState() external {
        string memory beforeUri = lensHtml.tokenURI();

        liquid.setMarketState(
            0.0042 ether,
            238 ether,
            79_228_162_514_264_337_593_543_950_336,
            -420,
            88_000,
            640_000 ether
        );
        liquid.setLaunchState(
            ILiquidBase.LaunchType.MULTICURVE,
            true,
            address(0),
            address(0)
        );

        assertNotEq(beforeUri, lensHtml.tokenURI());
    }

    function test_LensHtmlCanBeRegisteredAsLiquidRender() external {
        vm.prank(creator);
        liquid.setRenderContract(address(lensHtml));

        assertEq(liquid.tokenURI(), lensHtml.tokenURI());
    }

    function test_Mintable721SvgSupportsPassthroughAndTokenMetadata() external {
        uint256 tokenIdOne = lensMintable721.mint(collector);
        uint256 tokenIdTwo = lensMintable721.mint(collector);

        assertEq(tokenIdOne, 1);
        assertEq(tokenIdTwo, 2);
        assertEq(lensMintable721.ownerOf(tokenIdTwo), collector);
        assertTrue(
            _startsWith(
                lensMintable721.tokenURI(),
                "data:application/json;base64,"
            )
        );
        assertTrue(
            _startsWith(
                lensMintable721.tokenURI(tokenIdOne),
                "data:application/json;base64,"
            )
        );
        assertNotEq(
            lensMintable721.tokenURI(),
            lensMintable721.tokenURI(tokenIdOne)
        );
        assertNotEq(
            lensMintable721.tokenURI(tokenIdOne),
            lensMintable721.tokenURI(tokenIdTwo)
        );
    }

    function test_Mintable721SvgCanBeRegisteredAsLiquidRender() external {
        vm.prank(creator);
        liquid.setRenderContract(address(lensMintable721));

        assertEq(liquid.tokenURI(), lensMintable721.tokenURI());
    }

    function _startsWith(
        string memory text,
        string memory prefix
    ) internal pure returns (bool) {
        bytes memory textBytes = bytes(text);
        bytes memory prefixBytes = bytes(prefix);

        if (prefixBytes.length > textBytes.length) {
            return false;
        }

        for (uint256 i; i < prefixBytes.length; ++i) {
            if (textBytes[i] != prefixBytes[i]) {
                return false;
            }
        }

        return true;
    }
}
