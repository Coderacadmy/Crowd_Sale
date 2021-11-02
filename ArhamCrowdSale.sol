pragma solidity ^0.5.0;

import "./ArhamCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

contract ArhamCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {

    // Token Distribution
  uint256 public contributersPercentage   = 60;
  uint256 public foundersPercentage       = 12;
  uint256 public charitablePercentage     = 15;
  uint256 public advisorsPercentage       = 5;
  uint256 public bountyPercentage         = 3;
  uint256 public bonusPercentage          = 5;

  // Token reserve funds
  address public foundersFound;
  address public charitableFound;
  address public advisorsFound;
  address public bountyFounds;
  address public bonusFounds;
  
    constructor(
        uint rate, // rate in TKNbits
        address payable wallet, // sale beneficiary
        ArhamCoin token, // the ArhamCoin itself that the ArhamCoinSale will work with
        uint goal,
        uint open,
        uint close,
        address _foundationFounds,
        address _charitableFounds,
        address _advisorsFound,
        address _bountyFounds,
        address _bonusFounds
    )
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(goal)
        TimedCrowdsale(open, close)
        RefundableCrowdsale(goal)
        public
    {
        foundationFound = _foundationFounds;
        charitableFound = _charitableFounds;
        advisorsFound = _advisorsFound;
        bountyFounds = _bountyFounds;
        bonusFounds = _bonusFounds;
    }
}

contract ArhamCoinSaleDeployer {

    address public token_sale_address;
    address public token_address;

    constructor(
        string memory name,
        string memory symbol,
        address payable wallet, // this address will receive all Ether raised by the sale
        uint goal
    )
        public
    {
        // create the ArhamCoin and keep its address handy
        ArhamCoin token = new ArhamCoin(name, symbol, 0);
        token_address = address(token);

        // create the ArhamCoinSale and tell it about the token
        ArhamCoinSale token_sale = new ArhamCoinSale(1, wallet, token, goal, now, now + 24 weeks);
        token_sale_address = address(token_sale);

        // make the ArhamCoinSale contract a minter, then have the ArhamCoinSaleDeployer renounce its minter role
        token.addMinter(token_sale_address);
        token.renounceMinter();
    }
}
