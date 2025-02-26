// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
contract RebaseToken is ERC20{
    error RebaseToken__InterestReteCanOnlyDecrease(uint256 oldInterestRate, uint256 newInterestRate);

    uint256 private constant PRECISION_FACTOR = 1e18;
    uint256 private s_interestRate = 5e10;
    mapping(address => uint256) private s_userInterestRate;
        mapping(address => uint256) private s_userLastUpdatedTimestamp;

        event InterestRateSet(uint256 newInterestRate);
        constructor() ERC20("Rabase Token", "RBT") {
 
        }

        function setInterestRate(uint256 _newInterestRate) external {
            if(_newInterestRate < s_interestRate){
                revert RebaseToken__InterestReteCanOnlyDecrease(s_interestRate, _newInterestRate);
            }
            s_interestRate = _newInterestRate;
            emit InterestRateSet(_newInterestRate);
        }

        function mint(address _to, uint256 _amount) external {
            _mintAccruesInterest(_to);
            s_userInterestRate[_to] = s_interestRate;
            _mint(_to, _amount);
        }

        function balanceOf(address _user) public view override returns (uint256) {
            return super.balanceOf(_user) + _calculateUserAccumulatedInterestSinceLastUpdate(_user) / PRECISION_FACTOR;
        }

        function _calculateUserAccumulatedInterestSinceLastUpdate(address _user) internal view returns (uint256 linearInterest) {

            uint256 timeElapsed = block.timestamp - s_userLastUpdatedTimestamp[_user];
            linearInterest = (PRECISION_FACTOR * (s_userInterestRate[_user] * timeElapsed));
        }

        function _mintAccruesInterest(address _user) internal {
            s_userLastUpdatedTimestamp[_user] = block.timestamp;
        }

        function getUserInterestRate(address _user) external view returns (uint256) {
            return s_userInterestRate[_user];
        }
}