// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";

interface IRewardToken is IERC20Upgradeable {
	function mint(address account, uint256 amount) external;
	function burn(address account, uint256 amount) external;
}