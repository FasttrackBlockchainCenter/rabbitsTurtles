// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

contract RewardToken is ERC20Upgradeable, AccessControlUpgradeable {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

	// IMPORTANT - Decimals of the token is 2
	function initialize(string memory name_, string memory symbol_) initializer public {
		__ERC20_init(name_, symbol_);
        __AccessControl_init();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
	}

	function mint(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
		_mint(account, amount);
	}

	function burn(address account, uint256 amount) public onlyRole(MINTER_ROLE) {
		_burn(account, amount);
	}
}