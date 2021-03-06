pragma solidity >=0.6.0;
pragma AbiHeader expire;

import "4_interfaces.sol";

// This contract implements 'ICurrencyExchange' interface.
// The contract calls remote bank contract to get the exchange rate via callback function calling.
contract CurrencyExchange is ICurrencyExchange {

	// State variable storing the exchange rate.
	uint32 exchangeRate;

	constructor () public {
		// check that contract's public key is set
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	modifier checkOwnerAndAccept {
		// Check that message was signed with contracts key.
		require(tvm.pubkey() == msg.pubkey(), 101);
		tvm.accept();
		_;
	}

	// This function gets an address of the contract and code of the currency <code>,
	// casts the address to IRemoteContract interface and calls
	// function 'GetExchangeRate' with parameter <code>.
	function updateExchangeRate(address bankAddress, uint16 currency) external view checkOwnerAndAccept {
		ICentralBank(bankAddress).getExchangeRate(currency);
	}

	// A callback function to set exchangeRate.
	function setExchangeRate(uint32 er) external override {
		// save parameter er in state variable 'exchangeRate'.
		exchangeRate = er;
	}

	/*
	 * Public Getters
 	*/
	function getExchangeRate() public returns (uint rate) {
		rate = exchangeRate;
	}
}
