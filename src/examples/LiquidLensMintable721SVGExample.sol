// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Base64} from "../utils/Base64.sol";
import {ILiquid} from "../interfaces/ILiquid.sol";
import {ILiquidBase} from "../interfaces/ILiquidBase.sol";
import {SimpleERC721} from "../token/SimpleERC721.sol";

/// @notice Mintable ERC721 SVG example that also exposes tokenURI() for Liquid passthrough.
/// @dev This file is intentionally self-contained so artists can customize one contract directly.
contract LiquidLensMintable721SVGExample is SimpleERC721 {
    address public immutable LIQUID_EDITION;
    string public collectionDescription;
    string public externalUrl;
    uint256 public immutable maxSupply;
    uint256 public totalMinted;

    error InvalidLiquidEdition();
    error InvalidMaxSupply();
    error MaxSupplyReached();

    struct Snapshot {
        string tokenName;
        string tokenSymbol;
        uint256 rarePerToken;
        uint256 tokenPerRare;
        uint160 sqrtPriceX96;
        int24 currentTick;
        uint128 liquidity;
        uint256 currentSupply;
        uint256 maxTotalSupply;
        ILiquidBase.LaunchType launchType;
        bool poolLive;
        address creator;
    }

    struct Palette {
        string bg;
        string card;
        string text;
        string accent;
    }

    constructor(
        address liquidEdition,
        string memory name_,
        string memory symbol_,
        string memory description_,
        string memory externalUrl_,
        uint256 maxSupply_
    ) SimpleERC721(name_, symbol_) {
        if (liquidEdition == address(0)) revert InvalidLiquidEdition();
        if (maxSupply_ == 0) revert InvalidMaxSupply();

        LIQUID_EDITION = liquidEdition;
        collectionDescription = description_;
        externalUrl = externalUrl_;
        maxSupply = maxSupply_;
    }

    function mint(address to) external onlyOwner returns (uint256 tokenId) {
        if (totalMinted >= maxSupply) revert MaxSupplyReached();

        tokenId = totalMinted + 1;
        totalMinted = tokenId;
        _safeMint(to, tokenId);
    }

    /// @notice Metadata entrypoint for the Liquid token when this contract is registered as its renderer.
    function tokenURI() external view returns (string memory) {
        return _metadataFor(0, false);
    }

    /// @notice ERC721 metadata entrypoint for minted NFTs.
    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        _requireOwned(tokenId);
        return _metadataFor(tokenId, true);
    }

    function _metadataFor(
        uint256 serial,
        bool isMintedToken
    ) internal view returns (string memory) {
        Snapshot memory s = _snapshot();
        string memory svg = _renderSvg(s, serial, isMintedToken);
        string memory imageDataUri = string.concat(
            "data:image/svg+xml;base64,",
            Base64.encode(bytes(svg))
        );
        string memory metadataName = isMintedToken
            ? string.concat(name, " #", _toString(serial))
            : string.concat(name, " / Liquid passthrough");

        string memory json = string.concat(
            '{"name":"',
            _escapeJson(metadataName),
            '","description":"',
            _escapeJson(collectionDescription),
            '","external_url":"',
            _escapeJson(externalUrl),
            '","image":"',
            imageDataUri,
            '","attributes":',
            _attributes(s, serial, isMintedToken),
            "}"
        );

        return
            string.concat(
                "data:application/json;base64,",
                Base64.encode(bytes(json))
            );
    }

    function _snapshot() internal view returns (Snapshot memory s) {
        ILiquid liquid = ILiquid(LIQUID_EDITION);

        s.tokenName = liquid.name();
        s.tokenSymbol = liquid.symbol();
        s.creator = liquid.tokenCreator();
        s.maxTotalSupply = liquid.maxTotalSupply();
        (
            s.rarePerToken,
            s.tokenPerRare,
            s.sqrtPriceX96,
            s.currentTick,
            s.liquidity,
            s.currentSupply
        ) = liquid.getMarketState();

        try liquid.getLaunchState() returns (
            ILiquidBase.LaunchType launchType,
            bool poolLive,
            address,
            address
        ) {
            s.launchType = launchType;
            s.poolLive = poolLive;
        } catch {
            s.launchType = ILiquidBase.LaunchType.INSTANT;
            s.poolLive = true;
        }
    }

    function _attributes(
        Snapshot memory s,
        uint256 serial,
        bool isMintedToken
    ) internal pure returns (string memory) {
        return
            string.concat(
                "[",
                '{"trait_type":"Example","value":"Mintable 721 SVG"},',
                '{"trait_type":"Context","value":"',
                isMintedToken ? "Minted NFT" : "Liquid Passthrough",
                '"},',
                '{"trait_type":"Serial","value":"',
                _toString(serial),
                '"},',
                '{"trait_type":"Launch Type","value":"',
                _launchTypeLabel(s.launchType),
                '"},',
                '{"trait_type":"Price (RARE)","value":"',
                _formatFixed(s.rarePerToken, 6),
                '"},',
                '{"trait_type":"Supply","value":"',
                _formatFixed(s.currentSupply, 0),
                '"},',
                '{"trait_type":"Tick","value":"',
                _toStringSigned(s.currentTick),
                '"},',
                '{"trait_type":"Liquidity","value":"',
                _toString(uint256(s.liquidity)),
                '"}]'
            );
    }

    function _renderSvg(
        Snapshot memory s,
        uint256 serial,
        bool isMintedToken
    ) internal view returns (string memory) {
        Palette memory palette = _palette(s.currentTick, serial);
        uint256 burnBps = _burnBps(s.currentSupply, s.maxTotalSupply);

        return
            string.concat(
                '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 900">',
                '<style>.label{font:600 18px monospace}.value{font:700 32px monospace}.tiny{font:500 14px monospace}</style>',
                '<rect width="900" height="900" fill="#',
                palette.bg,
                '"/>',
                _rings(serial, palette),
                _bars(s, burnBps, palette),
                _copy(s, serial, isMintedToken, palette),
                "</svg>"
            );
    }

    function _rings(
        uint256 serial,
        Palette memory palette
    ) internal pure returns (string memory out) {
        out = string.concat(
            '<g fill="none" stroke="#',
            palette.accent,
            '" stroke-width="2">'
        );

        for (uint256 i; i < 7; ++i) {
            uint256 radius = 92 + (i * 42) + ((serial * 7 + i * 13) % 21);
            out = string.concat(
                out,
                '<circle cx="450" cy="290" r="',
                _toString(radius),
                '" stroke-opacity="',
                _opacity(i),
                '"/>'
            );
        }

        return string.concat(out, "</g>");
    }

    function _bars(
        Snapshot memory s,
        uint256 burnBps,
        Palette memory palette
    ) internal pure returns (string memory out) {
        uint256[4] memory values;
        values[0] = burnBps;
        values[1] = s.rarePerToken % 10_000;
        values[2] = uint256(uint24(_absTick(s.currentTick))) % 10_000;
        values[3] = uint256(s.liquidity) % 10_000;

        string[4] memory labels;
        labels[0] = "BURN";
        labels[1] = "PRICE";
        labels[2] = "TICK";
        labels[3] = "LIQ";

        for (uint256 i; i < 4; ++i) {
            uint256 x = 96 + (i * 186);
            uint256 height = 24 + (values[i] % 92);
            out = string.concat(
                out,
                '<g transform="translate(',
                _toString(x),
                ',660)"><rect width="138" height="146" rx="18" fill="#',
                palette.card,
                '" stroke="#',
                palette.text,
                '" stroke-opacity="0.14"/><rect x="22" y="',
                _toString(118 - height),
                '" width="94" height="',
                _toString(height),
                '" rx="10" fill="#',
                palette.accent,
                '" fill-opacity="0.90"/><text x="22" y="26" fill="#',
                palette.text,
                '" class="tiny">',
                labels[i],
                "</text></g>"
            );
        }
    }

    function _copy(
        Snapshot memory s,
        uint256 serial,
        bool isMintedToken,
        Palette memory palette
    ) internal view returns (string memory) {
        return
            string.concat(
                '<text x="96" y="118" fill="#',
                palette.text,
                '" class="label">',
                _escapeSvg(name),
                "</text><text x=\"96\" y=\"164\" fill=\"#",
                palette.accent,
                '" class="value">',
                _escapeSvg(s.tokenSymbol),
                "</text><text x=\"96\" y=\"204\" fill=\"#",
                palette.text,
                '" class="tiny">',
                isMintedToken
                    ? "Minted ERC721 token / tokenURI(uint256)"
                    : "Liquid passthrough / tokenURI()",
                "</text><text x=\"560\" y=\"118\" fill=\"#",
                palette.text,
                '" class="tiny">SERIAL</text><text x="560" y="160" fill="#',
                palette.accent,
                '" class="value">',
                _toString(serial),
                "</text><text x=\"560\" y=\"204\" fill=\"#",
                palette.text,
                '" class="tiny">PRICE ',
                _escapeSvg(_formatFixed(s.rarePerToken, 4)),
                "</text><text x=\"96\" y=\"600\" fill=\"#",
                palette.text,
                '" class="tiny">LAUNCH ',
                _escapeSvg(_launchTypeLabel(s.launchType)),
                " / TICK ",
                _escapeSvg(_toStringSigned(s.currentTick)),
                "</text><text x=\"560\" y=\"600\" fill=\"#",
                palette.text,
                '" class="tiny">CREATOR ',
                _escapeSvg(_shortAddress(s.creator)),
                "</text>"
            );
    }

    function _palette(
        int24 tick,
        uint256 serial
    ) internal pure returns (Palette memory) {
        uint256 paletteId = (uint256(uint24(_absTick(tick))) + serial) % 4;

        if (paletteId == 0) {
            return Palette("0D1117", "161B22", "E6EDF3", "58A6FF");
        }
        if (paletteId == 1) {
            return Palette("FAF4EA", "EFE2CD", "1C140D", "B86A26");
        }
        if (paletteId == 2) {
            return Palette("101010", "1E1E1E", "F6F3EE", "F04D3A");
        }

        return Palette("EEF3F6", "DCE7ED", "13212B", "247BA0");
    }

    function _burnBps(
        uint256 currentSupply,
        uint256 maxTotalSupply
    ) internal pure returns (uint256) {
        if (maxTotalSupply == 0 || currentSupply >= maxTotalSupply) {
            return 0;
        }

        return ((maxTotalSupply - currentSupply) * 10_000) / maxTotalSupply;
    }

    function _launchTypeLabel(
        ILiquidBase.LaunchType launchType
    ) internal pure returns (string memory) {
        if (launchType == ILiquidBase.LaunchType.GRADUATED) {
            return "GRADUATED";
        }
        if (launchType == ILiquidBase.LaunchType.MULTICURVE) {
            return "MULTICURVE";
        }
        return "INSTANT";
    }

    function _formatFixed(
        uint256 value,
        uint256 decimals
    ) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 whole = value / 1e18;
        if (decimals == 0) return _toString(whole);

        uint256 divisor = 10 ** (18 - decimals);
        uint256 fraction = (value / divisor) % (10 ** decimals);
        string memory fractionText = _toString(fraction);

        while (bytes(fractionText).length < decimals) {
            fractionText = string.concat("0", fractionText);
        }

        return string.concat(_toString(whole), ".", fractionText);
    }

    function _toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";

        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }

    function _toStringSigned(
        int256 value
    ) internal pure returns (string memory) {
        if (value >= 0) return _toString(uint256(value));
        return string.concat("-", _toString(uint256(-value)));
    }

    function _shortAddress(
        address account
    ) internal pure returns (string memory) {
        bytes memory full = bytes(_toHexString(account));
        bytes memory short = new bytes(13);
        short[0] = full[0];
        short[1] = full[1];
        short[2] = full[2];
        short[3] = full[3];
        short[4] = full[4];
        short[5] = full[5];
        short[6] = ".";
        short[7] = ".";
        short[8] = ".";
        short[9] = full[38];
        short[10] = full[39];
        short[11] = full[40];
        short[12] = full[41];
        return string(short);
    }

    function _toHexString(
        address account
    ) internal pure returns (string memory) {
        bytes20 value = bytes20(account);
        bytes memory buffer = new bytes(42);
        buffer[0] = "0";
        buffer[1] = "x";

        for (uint256 i; i < 20; ++i) {
            uint8 b = uint8(value[i]);
            buffer[2 + (i * 2)] = _hexChar(b >> 4);
            buffer[3 + (i * 2)] = _hexChar(b & 0x0f);
        }

        return string(buffer);
    }

    function _hexChar(uint8 nibble) internal pure returns (bytes1) {
        return nibble < 10 ? bytes1(nibble + 48) : bytes1(nibble + 87);
    }

    function _escapeJson(
        string memory value
    ) internal pure returns (string memory) {
        bytes memory source = bytes(value);
        bytes memory escaped;

        for (uint256 i; i < source.length; ++i) {
            bytes1 char = source[i];
            if (char == 0x22) {
                escaped = abi.encodePacked(escaped, "\\\"");
            } else if (char == 0x5c) {
                escaped = abi.encodePacked(escaped, "\\\\");
            } else {
                escaped = abi.encodePacked(escaped, char);
            }
        }

        return string(escaped);
    }

    function _escapeSvg(
        string memory value
    ) internal pure returns (string memory) {
        bytes memory source = bytes(value);
        bytes memory escaped;

        for (uint256 i; i < source.length; ++i) {
            bytes1 char = source[i];
            if (char == 0x26) {
                escaped = abi.encodePacked(escaped, "&amp;");
            } else if (char == 0x3c) {
                escaped = abi.encodePacked(escaped, "&lt;");
            } else if (char == 0x3e) {
                escaped = abi.encodePacked(escaped, "&gt;");
            } else {
                escaped = abi.encodePacked(escaped, char);
            }
        }

        return string(escaped);
    }

    function _opacity(uint256 index) internal pure returns (string memory) {
        if (index == 0) return "0.82";
        if (index == 1) return "0.66";
        if (index == 2) return "0.54";
        if (index == 3) return "0.42";
        if (index == 4) return "0.30";
        if (index == 5) return "0.22";
        return "0.14";
    }

    function _absTick(int24 value) internal pure returns (int24) {
        return value < 0 ? -value : value;
    }
}
