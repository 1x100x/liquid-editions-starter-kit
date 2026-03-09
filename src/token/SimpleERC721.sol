// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC165 {
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

interface IERC721 is IERC165 {
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
    function safeTransferFrom(address from, address to, uint256 tokenId) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function setApprovalForAll(address operator, bool approved) external;
    function getApproved(uint256 tokenId) external view returns (address);
    function isApprovedForAll(address owner, address operator) external view returns (bool);
    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;
}

interface IERC721Metadata is IERC721 {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function tokenURI(uint256 tokenId) external view returns (string memory);
}

interface IERC721Receiver {
    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data)
        external
        returns (bytes4);
}

abstract contract SimpleERC721 is IERC721Metadata {
    error ERC721InvalidOwner(address owner);
    error ERC721InvalidReceiver(address receiver);
    error ERC721IncorrectOwner(address sender, uint256 tokenId, address owner);
    error ERC721InsufficientApproval(address operator, uint256 tokenId);
    error ERC721NonexistentToken(uint256 tokenId);
    error OwnableUnauthorizedAccount(address account);

    string public name;
    string public symbol;
    address public owner;

    mapping(uint256 tokenId => address owner) internal _ownerOf;
    mapping(address owner => uint256 balance) internal _balanceOf;
    mapping(uint256 tokenId => address approved) internal _tokenApprovals;
    mapping(address owner => mapping(address operator => bool approved)) internal _operatorApprovals;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert OwnableUnauthorizedAccount(msg.sender);
        }
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        name = name_;
        symbol = symbol_;
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC721).interfaceId
            || interfaceId == type(IERC721Metadata).interfaceId;
    }

    function balanceOf(address tokenOwner) public view returns (uint256) {
        if (tokenOwner == address(0)) {
            revert ERC721InvalidOwner(address(0));
        }

        return _balanceOf[tokenOwner];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address tokenOwner = _ownerOf[tokenId];

        if (tokenOwner == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }

        return tokenOwner;
    }

    function approve(address to, uint256 tokenId) external {
        address tokenOwner = ownerOf(tokenId);

        if (msg.sender != tokenOwner && !_operatorApprovals[tokenOwner][msg.sender]) {
            revert ERC721InsufficientApproval(msg.sender, tokenId);
        }

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        ownerOf(tokenId);
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) external {
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address tokenOwner, address operator) public view returns (bool) {
        return _operatorApprovals[tokenOwner][operator];
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        address tokenOwner = ownerOf(tokenId);

        if (tokenOwner != from) {
            revert ERC721IncorrectOwner(from, tokenId, tokenOwner);
        }

        if (!_isApprovedOrOwner(msg.sender, tokenId, tokenOwner)) {
            revert ERC721InsufficientApproval(msg.sender, tokenId);
        }

        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        _transfer(from, to, tokenId);
    }

    function safeTransferFrom(address from, address to, uint256 tokenId) external {
        safeTransferFrom(from, to, tokenId, "");
    }

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public {
        transferFrom(from, to, tokenId);
        _checkOnERC721Received(from, to, tokenId, data);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableUnauthorizedAccount(address(0));
        }

        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _mint(address to, uint256 tokenId) internal {
        if (to == address(0)) {
            revert ERC721InvalidReceiver(address(0));
        }

        if (_ownerOf[tokenId] != address(0)) {
            revert ERC721IncorrectOwner(address(0), tokenId, _ownerOf[tokenId]);
        }

        _ownerOf[tokenId] = to;
        _balanceOf[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }

    function _safeMint(address to, uint256 tokenId) internal {
        _mint(to, tokenId);
        _checkOnERC721Received(address(0), to, tokenId, "");
    }

    function _requireOwned(uint256 tokenId) internal view {
        if (_ownerOf[tokenId] == address(0)) {
            revert ERC721NonexistentToken(tokenId);
        }
    }

    function _isApprovedOrOwner(address operator, uint256 tokenId, address tokenOwner) internal view returns (bool) {
        return
            operator == tokenOwner || _tokenApprovals[tokenId] == operator || _operatorApprovals[tokenOwner][operator];
    }

    function _transfer(address from, address to, uint256 tokenId) internal {
        delete _tokenApprovals[tokenId];
        _ownerOf[tokenId] = to;
        _balanceOf[from] -= 1;
        _balanceOf[to] += 1;

        emit Approval(from, address(0), tokenId);
        emit Transfer(from, to, tokenId);
    }

    function _checkOnERC721Received(address from, address to, uint256 tokenId, bytes memory data) internal {
        if (to.code.length == 0) {
            return;
        }

        try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) {
            if (retval != IERC721Receiver.onERC721Received.selector) {
                revert ERC721InvalidReceiver(to);
            }
        } catch {
            revert ERC721InvalidReceiver(to);
        }
    }
}
