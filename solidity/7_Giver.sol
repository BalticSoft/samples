pragma solidity >=0.6.0;
pragma AbiHeader expire;

import "7_CrashContract.sol";

interface AbstractContract {
	function receiveTransfer(uint64 number) pure external;
}

//This contract allows to perform different kinds of currency transactions and control the result using the fallback function.
contract Giver {

	// State variable storing the number of times receive/fallback/onBounce function was called.
	uint counter = 0;

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

	onBounce(TvmSlice /*slice*/) external {
		++counter;
	}

	// This function can transfer currency to an existing contract with fallback
	// function.
	function transferToAddress(address destination, uint128 value) public view checkOwnerAndAccept {
		destination.transfer(value);
	}

	// This function calls an AbstractContract which would case a crash and call of onBounce function.
	function transferToAbstractContract(address destination, uint amount) public view checkOwnerAndAccept {
		AbstractContract(destination).receiveTransfer{value: amount}(123);
	}

	// This function call a CrashContract's function which would cause a crash during transaction
	// and call of onBounce function.
	function transferToCrashContract(address destination, uint amount) public view checkOwnerAndAccept {
		CrashContract(destination).doCrash{value: amount}();
	}

	// Function which allows to make a transfer to an arbitrary address.
	function transferToAddress2(address destination, uint128 value, bool bounce, uint16 flag)
		view
		public
		checkOwnerAndAccept
	{
		// Runtime function that allows to make a transfer with arbitrary settings
		// and can be used to send tons to non-existing address.
		destination.transfer(value, bounce, flag);
	}

	/*
	 * Public Getters
	 */
	function getCounter() public view returns (uint qty) {
		return counter;
	}
}
