pragma solidity 0.7.3;

interface IStrat {
    function invest() external; // underlying amount must be sent from vault to strat address before
    function divest(uint amount) external; // should send requested amount to vault directly, not less or more
    function harvestYields() external; // harvests yields from the strategy
    function calcTotalValue() external returns (uint);
}