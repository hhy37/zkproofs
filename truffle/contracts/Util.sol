pragma solidity ^0.4.24;
    
library Util {
    function _mylog2(uint x) public pure returns (uint y){
        assembly {
        let arg := x
		x := sub(x,1)
		x := or(x, div(x, 0x02))
		x := or(x, div(x, 0x04))
		x := or(x, div(x, 0x10))
		x := or(x, div(x, 0x100))
		x := or(x, div(x, 0x10000))
		x := or(x, div(x, 0x100000000))
		x := or(x, div(x, 0x10000000000000000))
		x := or(x, div(x, 0x100000000000000000000000000000000))
		x := add(x, 1)
		let m := mload(0x40)
		mstore(m,           0xf8f9cbfae6cc78fbefe7cdc3a1793dfcf4f0e8bbd8cec470b6a28a7a5a3e1efd)
		mstore(add(m,0x20), 0xf5ecf1b3e9debc68e1d9cfabc5997135bfb7a7a3938b7b606b5b4b3f2f1f0ffe)
		mstore(add(m,0x40), 0xf6e4ed9ff2d6b458eadcdf97bd91692de2d4da8fd2d0ac50c6ae9a8272523616)
		mstore(add(m,0x60), 0xc8c0b887b0a8a4489c948c7f847c6125746c645c544c444038302820181008ff)
		mstore(add(m,0x80), 0xf7cae577eec2a03cf3bad76fb589591debb2dd67e0aa9834bea6925f6a4a2e0e)
		mstore(add(m,0xa0), 0xe39ed557db96902cd38ed14fad815115c786af479b7e83247363534337271707)
		mstore(add(m,0xc0), 0xc976c13bb96e881cb166a933a55e490d9d56952b8d4e801485467d2362422606)
		mstore(add(m,0xe0), 0x753a6d1b65325d0c552a4d1345224105391a310b29122104190a110309020100)
		mstore(0x40, add(m, 0x100))
		let magic := 0x818283848586878898a8b8c8d8e8f929395969799a9b9d9e9faaeb6bedeeff
		let shift := 0x100000000000000000000000000000000000000000000000000000000000000
		let a := div(mul(x, magic), shift)
		y := div(mload(add(m,sub(255,a))), shift)
		y := add(y, mul(256, gt(arg, 0x8000000000000000000000000000000000000000000000000000000000000000)))
        }  
    }
    
    function uint256ToStr(uint256 i) internal pure 
    	returns (string memory){
        if (i == 0) return "0";
        uint256 j = i;
        uint length;
        while (j != 0){
            length++;
            j /= 10;
        }
        bytes memory bstr = new bytes(length);
        uint k = length - 1;
        while (i != 0){
            bstr[k--] = byte(48 + i % 10);
            i /= 10;
        }
        return string(bstr);
    }

    function stringToUint256(string memory s) internal pure 
    	returns (uint256, bool) {
        bool hasError = false;
        bytes memory b = bytes(s);
        uint256 result = 0;
        uint256 oldResult = 0;
        for (uint i = 0; i < b.length; i++) { // c = b[i] was not needed
            if (b[i] >= 48 && b[i] <= 57) {
                // store old value so we can check for overflows
                oldResult = result;
                result = result * 10 + (uint256(b[i]) - 48); // bytes and int are not compatible with the operator -.
                // prevent overflows
                if(oldResult > result ) {
                    // we can only get here if the result overflowed and is smaller than last stored value
                    hasError = true;
                }
            } else {
                hasError = true;
            }
        }
        return (result, hasError); 
    }    
    
    function hashBP(uint256 xA, uint256 yA, uint256 xS, uint256 yS) public pure 
        returns (uint256 result1, uint256 result2) {
	bytes memory concat = abi.encodePacked(uint256ToStr(xA), uint256ToStr(yA), uint256ToStr(xS), uint256ToStr(yS));
	result1 = uint256(sha256(concat));
	bytes memory next_concat = abi.encodePacked(concat, uint256ToStr(result1));
	result2 = uint256(sha256(next_concat));
    } 
}
