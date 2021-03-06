pragma solidity >=0.6.0;
pragma AbiHeader expire;

import "11_SimpleContract.sol";

contract ContractDeployer {

	// addresses of deployed contracts
	address[] contracts;

	constructor () public {
		require(tvm.pubkey() != 0);
		tvm.accept();
	}

	// Modifier that allows public function to accept external calls only from the contract owner.
	modifier checkOwnerAndAccept {
		require(tvm.pubkey() == msg.pubkey(), 101);
		tvm.accept();
		_;
	}

	// First variant of contract deployment.
	function deployWithPubkey(
		TvmCell stateInit,
		uint256 pubkey,
		uint128 initialBalance,
		uint paramA,
		uint32 paramB
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function that inserts public key into contracts data field.
		TvmCell stateInitWithKey = tvm.insertPubkey(stateInit, pubkey);

		// Deploy a contract and call it's constructor.
		address addr = new SimpleContract{stateInit: stateInitWithKey, value: initialBalance}(paramA, paramB);

		// save address
		contracts.push(addr);
	}


	// Second variant of contract deployment.
	function deployFromCodeAndData(
		TvmCell code,
		TvmCell data,
		uint128 initialBalance,
		uint paramA,
		uint32 paramB
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function to generate StateInit from code and data cells.
		TvmCell stateInit = tvm.buildStateInit(code, data);

		address addr = new SimpleContract{stateInit: stateInit, value: initialBalance}(paramA, paramB);

		// save address
		contracts.push(addr);
	}


	// Third variant of contract deployment.
	function deployWithMsgBody(
		TvmCell stateInit,
		address addr,
		uint128 initialBalance,
		TvmCell payload
	)
		public
		checkOwnerAndAccept
	{
		// Runtime function to deploy contract with prepared msg body for constructor call.
		tvm.deploy(stateInit, addr, initialBalance, payload);

		// save address
		contracts.push(addr);
	}

	/*
	 * Public Getters
	 */
	// Function that allows to get information about contract with given ID.
	function getAddrs() public view returns (address[] addrs) {
		addrs = contracts;
	}
}
