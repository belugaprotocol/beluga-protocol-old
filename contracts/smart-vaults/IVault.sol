pragma solidity 0.7.3;

interface IVault {
    function totalSupply() view external returns (uint);
    function harvest(uint amount) external returns (uint afterFee);
    function distribute(uint amount) external;
    function underlying() external view returns (IERC20Detailed);
    function target() external view returns (IERC20);
    function owner() external view returns (address);
    function timelock() external view returns (address payable);
    function claimOnBehalf(address recipient) external;
    function lastDistribution() view external returns (uint);
}