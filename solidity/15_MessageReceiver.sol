pragma solidity >= 0.6.0;

// Contract that parses the argument passed to his function.
contract MessageReceiver {

	// State variable storing the number of times 'receiveMessage' function was called.
	uint counter;

	constructor() public {
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	// Function to be called from another contract. This function gets TvmCell argument and parses data from it.
	// Reserved keyword "functionID" allows to set function identifier manually.
	function receiveMessage(TvmCell cell) public functionID(0x12345678) {
		// Function toSlice allows to convert cell into slice.
		TvmSlice slice = cell.toSlice();
		// Function size() returns size of data bits and number of refs in slice.
		(uint16 bits, uint8 refs) = slice.size();
		require(bits == 0, 101);
		require(refs == 1, 102);
		// Function loadRefAsSlice() allows to load a cell from slice ref and convert it into a slice.
		TvmSlice slice2 = slice.loadRefAsSlice();
		require(slice2.bits() == 267 + 16 + 8 + 11, 103);
		// Function decode() allows to load arbitrary types from slice.
		(address addr, uint16 val0, uint8 val1) = slice2.decode(address, uint16, uint8);
		require(addr.value == 123, 104);
		require(val0 == 123, 105);
		require(val1 == 123, 106);
		// Function loadUnsigned() allows to load an unsigned integer of arbitrary bitsize.
		uint val2 = slice2.loadUnsigned(11);
		require(val2 == 123, 107);
		counter++;
	}

	/*
	 * Public Getters
	 */
	function getCounter() public view returns (uint c) {
		return counter;
	}
}
