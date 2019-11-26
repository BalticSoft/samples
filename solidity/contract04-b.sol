pragma solidity ^0.5.0;

contract IRemoteContract {
	function remoteMethod(uint16 x) public;
}

contract IRemoteContractCallback {
	function remoteMethodCallback(uint16 x) public;
}

contract RemoteContract is IRemoteContract {

	function tvm_accept() private pure {}
	
	modifier alwaysAccept {
		tvm_accept(); _;
	}

	uint16 m_value;
	
	// A function to be called from another contract
	function remoteMethod(uint16 x) public alwaysAccept {
		// save parameter x in the state variable 'm_value'
		m_value = x;
		// cast address of caller to IRemoteContractCallback interface and
		// call its 'remoteMethodCallback' method
		IRemoteContractCallback(msg.sender).remoteMethodCallback(x * 16);
		return; 
	}
	
}