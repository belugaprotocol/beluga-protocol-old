pragma solidity ^0.6.12;

import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/math/SafeMathUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// @title Hardworker v1.0
// @notice Distributes vault fees to BELUGA stakers

interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

contract Hardworker is OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;
    using AddressUpgradeable for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    address public stakingPool;
    address public rewardToken;

    // @notice Swaps tokens the contract owns
    function swapTokens(address router, uint256 amount, address[] calldata route) public onlyOwner {
        IUniswapRouter(router).swapExactTokensForTokens(amount, 0, route, address(this), now.add(600));
    }

    // @notice Distributes rewards to stakers
    function rewardToStakers(uint256 amount) public onlyOwner {
        IERC20Upgradeable(rewardToken).safeTransfer(stakingPool, amount);
    }

    // @notice Allows owner to set the staking pool
    function setStakingPool(address pool) public onlyOwner {
        stakingPool = pool;
    }

    // @notice Allows owner to set the reward token
    function setRewardToken(address token) public onlyOwner {
        rewardToken = token;
    }

}