// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MagicNum {
    address public solver;

    constructor() {}

    function setSolver(address _solver) public {
        solver = _solver;
    }

    /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}

contract Deployer {
    event Deploy(address deployed);

    function deploy(bytes memory bytescode) public {
        address deployed;

        bytes memory deploycode = abi.encodePacked(
            hex"63",
            uint32(bytescode.length),
            hex"80_60_0E_60_00_39_60_00_F3",
            bytescode
        );

        assembly {
            deployed := create(0, add(deploycode, 32), mload(deploycode))
            if iszero(extcodesize(deployed)) {
                revert(0, 0)
            }
        }

        emit Deploy(deployed);
    }

    function getCode(
        address contractAddress
    ) public view returns (bytes memory) {
        return contractAddress.code;
    }
}

contract MeaningOfLife {
    constructor() {
        assembly {
            mstore(0, 0x602a60405260206040f3)
            return(22, 10)
        }
    }
}
