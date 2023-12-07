// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Soul is ERC1155, Ownable {
    uint256 public constant MAIN_TOKEN_ID = 1;
    mapping(address => bool) public hasSoulboundToken;

    error OnlySoulboundTokenOwner();
    error WalletAlreadyOwnsSoulboundToken();
    error CannotTransferSoulboundToken();

    modifier onlySoulboundTokenOwner() {
        require(
            hasSoulboundToken[msg.sender],
            "Only the owner of the soulbound main token can call this function."
        );
        _;
    }

    modifier cannotTransferSoulboundToken(address to) {
        require(
            to == address(0),
            "Cannot transfer the soulbound main token. It can only be burned by the token owner."
        );
        _;
    }

    constructor(address initialOwner) ERC1155("") Ownable(initialOwner) {
        _mint(initialOwner, MAIN_TOKEN_ID, 1, "");
        hasSoulboundToken[initialOwner] = true;
    }

    function mintSoulboundToken(address _to) external onlyOwner {
        if (hasSoulboundToken[_to]) {
            revert WalletAlreadyOwnsSoulboundToken();
        }
        _mint(_to, MAIN_TOKEN_ID, 1, "");
        hasSoulboundToken[_to] = true;
    }

    function mintItemToken(
        address _to,
        uint256 _id,
        uint256 _amount
    ) external onlySoulboundTokenOwner {
        _mint(_to, _id, _amount, "");
    }

    function transferItemToken(
        address _to,
        uint256 _id,
        uint256 _amount
    ) external onlySoulboundTokenOwner {
        safeTransferFrom(msg.sender, _to, _id, _amount, "");
    }

    function burnSoulboundToken(
        uint256 _amount
    )
        external
        onlySoulboundTokenOwner
        cannotTransferSoulboundToken(msg.sender)
    {
        _burn(msg.sender, MAIN_TOKEN_ID, _amount);
    }
}
