// SPDX-License-Identifier: None

pragma solidity ^0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Hardworker v2.0
/// @notice This contract is responsible for generating protocol profit
/// and distributing BELUGA rewards to stakers.

interface IUniswapRouter {
    function swapExactTokensForTokens(
        uint amountIn, 
        uint amountOutMin, 
        address[] calldata path, 
        address to, 
        uint deadline
    ) external returns (uint[] memory amounts);
}

interface IRewardPool {
    function notifyRewardAmount(uint256 rewards) external;
}

contract HardWorker is Ownable {
    using SafeMath for uint256;
    using Address for address;
    using SafeERC20 for IERC20;

    address public stakingPool;
    address public rewardToken;

    constructor(address _stakingPool, address _rewardToken) public {
        stakingPool = _stakingPool;
        rewardToken = _rewardToken;
    }

    /// @notice Swaps tokens the contract owns
    function swapTokens(address _token, address router, uint256 amount, address[] calldata route) public onlyOwner {
        uint256 tknBal = IERC20(_token).balanceOf(address(this));
        IERC20(_token).safeApprove(router, 0);
        IERC20(_token).safeApprove(router, tknBal);

        IUniswapRouter(router).swapExactTokensForTokens(amount, 0, route, address(this), now.add(600));
    }

    /// @notice Distributes rewards to stakers
    function rewardToStakers(uint256 amount) public onlyOwner {
        IERC20(rewardToken).safeTransfer(stakingPool, amount);
        IRewardPool(stakingPool).notifyRewardAmount(amount);
    }

    /// @notice Allows owner to set the staking pool
    function setStakingPool(address pool) public onlyOwner {
        stakingPool = pool;
    }

    /// @notice Allows owner to set the reward token
    function setRewardToken(address token) public onlyOwner {
        rewardToken = token;
    }

    /// @notice Function to transfer tokens out
    function transferOut(address token, address to, address amount) public onlyOwner {
        IERC20(token).safeTransfer(to, amount);
    }

    /// @notice Function for executing transactions
    /// @dev This function can be used to do anything and because of this,
    /// we give a multisig control over this contract to ensure a malicious 
    /// owner cannot do anything.

    function executeTransaction(bytes memory _code) public onlyOwner returns (address target) {
        assembly {
            target := create(0, add(_code, 0x20), mload(_code))
            switch iszero(extcodesize(target))
            case 1 {
                // throw if contract failed to deploy
                revert(0, 0)
            }
        }
        bytes32 hash = keccak256(_code);
        cache[hash] = target;
    }
    }

}