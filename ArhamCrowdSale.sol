pragma solidity ^0.5.0;

import "./ArhamCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/WhitelistCrowdsale.sol";
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
        uint _cap,
        uint _openingTime,
        uint _closingTime,
        uint _goal,
        address _foundersFounds,
        address _charitableFounds,
        address _advisorsFound,
        address _bountyFounds,
        address _bonusFounds
    )
        Crowdsale(rate, wallet, token)
        CappedCrowdsale(_cap)
        TimedCrowdsale(_openingTime, _closingTime)
        RefundableCrowdsale(_goal)
        public
    {   
        require (_goal <= _cap);
        foundersFound = _foundersFounds;
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
    
    /**
   * @dev enables token transfers, called when owner calls finalize()
  */
  function finalization() internal {
//    if(goalReached()) {
//      MintableToken _mintableToken = MintableToken(token);
      uint256 _alreadyMinted = _mintableToken.totalSupply();

      uint256 _finalTotalSupply = _alreadyMinted.div(tokenSalePercentage).mul(100);

      foundersTimelock   = new TokenTimelock(token, _foundersFund, releaseTime);
      charitableTimelock = new TokenTimelock(token, _charitableFounds, releaseTime);
      advasiorsTimelock   = new TokenTimelock(token, _advisorsFound, releaseTime);
      bountyTimelock   = new TokenTimelock(token, _bountyFounds, releaseTime);
      bonusTimelock   = new TokenTimelock(token, _bonusFounds, releaseTime);

      _mintableToken.mint(address(foundersTimelock),   _finalTotalSupply.mul(foundersPercentage).div(100));
      _mintableToken.mint(address(charitableTimelock), _finalTotalSupply.mul(charitablePercentage).div(100));
      _mintableToken.mint(address(advasiorsTimelock),   _finalTotalSupply.mul(advisorsPercentage).div(100));
      _mintableToken.mint(address(bountyTimelock),   _finalTotalSupply.mul(bountyPercentage).div(100));
      _mintableToken.mint(address(bonusTimelock),   _finalTotalSupply.mul(bonusPercentage).div(100));

      _mintableToken.finishMinting();
      // Unpause the token
      PausableToken _pausableToken = PausableToken(token);
      _pausableToken.unpause();
      _pausableToken.transferOwnership(wallet);
    }

    super.finalization();
  }

}
