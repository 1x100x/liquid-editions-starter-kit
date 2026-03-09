// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Base64} from "../utils/Base64.sol";
import {ILiquid} from "../interfaces/ILiquid.sol";
import {ILiquidBase} from "../interfaces/ILiquidBase.sol";

/// @notice Single-artwork HTML render example for a Liquid token.
/// @dev This contract is intentionally self-contained so artists can fork one file and edit in place.
contract LiquidLensHTMLExample {
    address public immutable LIQUID_EDITION;
    string public lensName;
    string public lensDescription;
    string public externalUrl;

    error InvalidLiquidEdition();

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
        string panel;
        string text;
        string accent;
    }

    constructor(address liquidEdition, string memory name_, string memory description_, string memory externalUrl_) {
        if (liquidEdition == address(0)) revert InvalidLiquidEdition();

        LIQUID_EDITION = liquidEdition;
        lensName = name_;
        lensDescription = description_;
        externalUrl = externalUrl_;
    }

    function tokenURI() external view returns (string memory) {
        Snapshot memory s = _snapshot();
        string memory previewSvg = _renderPreviewSvg(s);
        string memory imageDataUri = _imageDataUri(previewSvg);
        string memory htmlDataUri = _htmlDataUri(_renderHtmlPage(s, previewSvg));
        string memory attributes = _attributes(s);

        return
            _jsonDataUri(
                _buildJsonMetadata(lensName, lensDescription, externalUrl, imageDataUri, htmlDataUri, attributes)
            );
    }

    function _buildJsonMetadata(
        string memory name_,
        string memory description_,
        string memory externalUrl_,
        string memory imageDataUri,
        string memory htmlDataUri,
        string memory attributes
    ) internal pure returns (string memory) {
        return string.concat(
            '{"name":"',
            _escapeJson(name_),
            '","description":"',
            _escapeJson(description_),
            '","external_url":"',
            _escapeJson(externalUrl_),
            '","image":"',
            imageDataUri,
            '","animation_url":"',
            htmlDataUri,
            '","attributes":',
            attributes,
            "}"
        );
    }

    function _jsonDataUri(string memory json) internal pure returns (string memory) {
        return string.concat("data:application/json;base64,", Base64.encode(bytes(json)));
    }

    function _imageDataUri(string memory svg) internal pure returns (string memory) {
        return string.concat("data:image/svg+xml;base64,", Base64.encode(bytes(svg)));
    }

    function _htmlDataUri(string memory html) internal pure returns (string memory) {
        return string.concat("data:text/html;base64,", Base64.encode(bytes(html)));
    }

    function _snapshot() internal view returns (Snapshot memory s) {
        ILiquid liquid = ILiquid(LIQUID_EDITION);

        s.tokenName = liquid.name();
        s.tokenSymbol = liquid.symbol();
        s.creator = liquid.tokenCreator();
        s.maxTotalSupply = liquid.maxTotalSupply();
        (s.rarePerToken, s.tokenPerRare, s.sqrtPriceX96, s.currentTick, s.liquidity, s.currentSupply) =
            liquid.getMarketState();

        try liquid.getLaunchState() returns (ILiquidBase.LaunchType launchType, bool poolLive, address, address) {
            s.launchType = launchType;
            s.poolLive = poolLive;
        } catch {
            s.launchType = ILiquidBase.LaunchType.INSTANT;
            s.poolLive = true;
        }
    }

    function _attributes(Snapshot memory s) internal pure returns (string memory) {
        return string.concat(
            "[",
            '{"trait_type":"Example","value":"Single Artwork HTML"},',
            '{"trait_type":"Render Media","value":"HTML"},',
            '{"trait_type":"Launch Type","value":"',
            _launchTypeLabel(s.launchType),
            '"},',
            '{"trait_type":"Pool Live","value":"',
            s.poolLive ? "Yes" : "No",
            '"},',
            '{"trait_type":"Price (RARE)","value":"',
            _formatFixed(s.rarePerToken, 6),
            '"},',
            '{"trait_type":"Supply","value":"',
            _formatFixed(s.currentSupply, 0),
            '"},',
            '{"trait_type":"Liquidity","value":"',
            _toString(uint256(s.liquidity)),
            '"},',
            '{"trait_type":"Tick","value":"',
            _toStringSigned(s.currentTick),
            '"}]'
        );
    }

    function _renderPreviewSvg(Snapshot memory s) internal view returns (string memory) {
        Palette memory palette = _palette(s.currentTick);
        return string.concat(
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 900 900">',
            "<style>.label{font:600 18px monospace}.value{font:700 36px monospace}.tiny{font:500 14px monospace}</style>",
            '<rect width="900" height="900" fill="#',
            palette.bg,
            '"/>',
            _grid(palette),
            _priceBands(s, palette),
            _labels(s, palette),
            "</svg>"
        );
    }

    function _grid(Palette memory palette) internal pure returns (string memory out) {
        out = string.concat('<g stroke="#', palette.text, '" stroke-opacity="0.10" stroke-width="1">');

        for (uint256 i; i < 10; ++i) {
            uint256 offset = 90 + (i * 70);
            out = string.concat(
                out,
                '<line x1="90" y1="',
                _toString(offset),
                '" x2="810" y2="',
                _toString(offset),
                '"/><line x1="',
                _toString(offset),
                '" y1="90" x2="',
                _toString(offset),
                '" y2="810"/>'
            );
        }

        return string.concat(out, "</g>");
    }

    function _priceBands(Snapshot memory s, Palette memory palette) internal pure returns (string memory out) {
        out = string.concat('<g fill="none" stroke="#', palette.accent, '" stroke-width="5">');

        uint256 amplitude = 48 + (uint256(s.liquidity) % 120);
        uint256 baseline = 560;

        for (uint256 i; i < 8; ++i) {
            uint256 x1 = 120 + (i * 85);
            uint256 x2 = x1 + 85;
            uint256 wave =
                uint256(keccak256(abi.encodePacked(s.rarePerToken, s.currentSupply, s.currentTick, i))) % amplitude;
            uint256 y1 = baseline - wave;
            uint256 y2 = baseline - ((wave + (uint256(i) * 13)) % amplitude);
            out = string.concat(
                out,
                '<line x1="',
                _toString(x1),
                '" y1="',
                _toString(y1),
                '" x2="',
                _toString(x2),
                '" y2="',
                _toString(y2),
                '"/>'
            );
        }

        out = string.concat(
            out,
            '</g><rect x="120" y="640" width="660" height="110" rx="24" fill="#',
            palette.panel,
            '" stroke="#',
            palette.text,
            '" stroke-opacity="0.18"/>'
        );
    }

    function _labels(Snapshot memory s, Palette memory palette) internal view returns (string memory) {
        return string.concat(_labelsTop(s, palette), _labelsBottom(s, palette));
    }

    function _labelsTop(Snapshot memory s, Palette memory palette) internal view returns (string memory) {
        return string.concat(
            '<text x="120" y="136" fill="#',
            palette.text,
            '" class="label">',
            _escapeSvg(lensName),
            "</text><text x=\"120\" y=\"184\" fill=\"#",
            palette.accent,
            '" class="value">',
            _escapeSvg(s.tokenSymbol),
            "</text><text x=\"120\" y=\"220\" fill=\"#",
            palette.text,
            '" class="tiny">Single artwork HTML example / targeting ILiquid market state</text><text x="120" y="686" fill="#',
            palette.text,
            '" class="tiny">PRICE</text><text x="120" y="724" fill="#',
            palette.accent,
            '" class="value">',
            _escapeSvg(_formatFixed(s.rarePerToken, 4)),
            "</text>"
        );
    }

    function _labelsBottom(Snapshot memory s, Palette memory palette) internal pure returns (string memory) {
        return string.concat(
            '<text x="410" y="686" fill="#',
            palette.text,
            '" class="tiny">SUPPLY</text><text x="410" y="724" fill="#',
            palette.accent,
            '" class="value">',
            _escapeSvg(_formatFixed(s.currentSupply, 0)),
            "</text><text x=\"120\" y=\"780\" fill=\"#",
            palette.text,
            '" class="tiny">LAUNCH ',
            _escapeSvg(_launchTypeLabel(s.launchType)),
            " / TICK ",
            _escapeSvg(_toStringSigned(s.currentTick)),
            "</text><text x=\"410\" y=\"780\" fill=\"#",
            palette.text,
            '" class="tiny">CREATOR ',
            _escapeSvg(_shortAddress(s.creator)),
            "</text>"
        );
    }

    function _renderHtmlPage(Snapshot memory s, string memory previewSvg) internal view returns (string memory) {
        Palette memory palette = _palette(s.currentTick);

        return string.concat(_renderHtmlHead(palette), _renderHtmlIntro(), previewSvg, _renderHtmlStats(s));
    }

    function _renderHtmlHead(Palette memory palette) internal view returns (string memory) {
        return string.concat(
            "<!doctype html><html><head><meta charset='utf-8'><meta name='viewport' content='width=device-width,initial-scale=1'>",
            "<title>",
            _escapeHtml(lensName),
            "</title><style>body{margin:0;background:#",
            palette.bg,
            ";color:#",
            palette.text,
            ";font-family:ui-monospace,monospace}main{max-width:1120px;margin:0 auto;padding:28px;display:grid;gap:20px}section{background:#",
            palette.panel,
            ";border:1px solid rgba(255,255,255,0.10);border-radius:24px;padding:24px}h1{margin:0 0 8px 0}p{opacity:0.82}.stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px}.card{padding:14px;border-radius:16px;background:rgba(0,0,0,0.12)}strong{display:block;margin-top:4px;font-size:20px;color:#",
            palette.accent,
            "}</style></head><body><main>"
        );
    }

    function _renderHtmlIntro() internal view returns (string memory) {
        return string.concat(
            "<section><h1>",
            _escapeHtml(lensName),
            "</h1><p>",
            _escapeHtml(lensDescription),
            "</p></section><section>",
            ""
        );
    }

    function _renderHtmlStats(Snapshot memory s) internal pure returns (string memory) {
        return string.concat(
            "</section><section class='stats'><div class='card'><span>Token</span><strong>",
            _escapeHtml(s.tokenName),
            "</strong></div><div class='card'><span>Price</span><strong>",
            _formatFixed(s.rarePerToken, 6),
            "</strong></div><div class='card'><span>Supply</span><strong>",
            _formatFixed(s.currentSupply, 0),
            "</strong></div><div class='card'><span>Liquidity</span><strong>",
            _toString(uint256(s.liquidity)),
            "</strong></div><div class='card'><span>Tick</span><strong>",
            _toStringSigned(s.currentTick),
            "</strong></div><div class='card'><span>Pool Live</span><strong>",
            s.poolLive ? "Yes" : "No",
            "</strong></div></section></main></body></html>"
        );
    }

    function _palette(int24 tick) internal pure returns (Palette memory) {
        uint256 paletteId = uint256(uint24(_absTick(tick))) % 4;

        if (paletteId == 0) {
            return Palette("0B1020", "162038", "E4F1FF", "6BF2C1");
        }
        if (paletteId == 1) {
            return Palette("F7F1E6", "E8DCC7", "1F1A16", "B44C2B");
        }
        if (paletteId == 2) {
            return Palette("141414", "1F1F1F", "F5EFE6", "F6B233");
        }

        return Palette("EEF3F0", "D9E6DF", "163126", "2E7D5A");
    }

    function _launchTypeLabel(ILiquidBase.LaunchType launchType) internal pure returns (string memory) {
        if (launchType == ILiquidBase.LaunchType.GRADUATED) {
            return "GRADUATED";
        }
        if (launchType == ILiquidBase.LaunchType.MULTICURVE) {
            return "MULTICURVE";
        }
        return "INSTANT";
    }

    function _formatFixed(uint256 value, uint256 decimals) internal pure returns (string memory) {
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

    function _toStringSigned(int256 value) internal pure returns (string memory) {
        if (value >= 0) return _toString(uint256(value));
        return string.concat("-", _toString(uint256(-value)));
    }

    function _shortAddress(address account) internal pure returns (string memory) {
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

    function _toHexString(address account) internal pure returns (string memory) {
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

    function _escapeJson(string memory value) internal pure returns (string memory) {
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

    function _escapeSvg(string memory value) internal pure returns (string memory) {
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

    function _escapeHtml(string memory value) internal pure returns (string memory) {
        return _escapeSvg(value);
    }

    function _absTick(int24 value) internal pure returns (int24) {
        return value < 0 ? -value : value;
    }
}
