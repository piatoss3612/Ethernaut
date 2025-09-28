import {
  bytesToBigInt,
  recoverPublicKey,
  serializeSignature,
  toHex,
  verifyHash,
  type Hex,
} from "viem";
import { publicKeyToAddress } from "viem/accounts";
import { secp256k1 } from "@noble/curves/secp256k1.js";
import { randomBytes } from "crypto";

const N = BigInt(
  "0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141",
);

// ---------- helpers ----------
function mod(a: bigint, m: bigint): bigint {
  const r = a % m;
  return r >= 0n ? r : r + m;
}
function invMod(a: bigint, m: bigint): bigint {
  // Extended Euclidean Algorithm
  let t = 0n,
    newT = 1n;
  let r = m,
    newR = mod(a, m);
  while (newR !== 0n) {
    const q = r / newR;
    [t, newT] = [newT, t - q * newT];
    [r, newR] = [newR, r - q * newR];
  }
  if (r !== 1n) throw new Error("Inverse does not exist");
  if (t < 0n) t += m;
  return t;
}

function randomScalar(): bigint {
  while (true) {
    const rb = randomBytes(32);
    const k = bytesToBigInt(rb);
    const s = mod(k, N - 1n) + 1n; // 1..n-1
    if (s !== 0n) return s;
  }
}

async function signatureSpoofing({
  hash,
  signature,
}: {
  hash: Hex;
  signature: Hex;
}) {
  // Recover public key (should be uncompressed)
  const pubkeyHex = await recoverPublicKey({
    hash,
    signature,
  });

  // Build Q from pubkey
  const Q = secp256k1.Point.fromHex(pubkeyHex.slice(2));
  const G = secp256k1.Point.BASE;

  while (true) {
    const u1 = randomScalar();
    const u2 = randomScalar();
    if (u2 === 0n) continue;
    // P = u1*G + u2*Q
    const P = G.multiply(u1).add(Q.multiply(u2));
    const { x, y } = P.toAffine();
    const r = mod(x, N);
    if (r === 0n) continue;

    const u2Inv = invMod(u2, N);
    let s = mod(r * u2Inv, N);
    if (s === 0n) continue;

    let yParity = Number(y & 1n);
    // Enforce low-S canonical form
    if (s > N / 2n) {
      s = N - s;
      yParity ^= 1; // flip parity because we negated s
    }

    const v = 27 + yParity; // Ethereum-style v
    const e = mod(r * mod(u1 * u2Inv, N), N); // forged message hash

    const generatedSignature = serializeSignature({
      r: toHex(r),
      s: toHex(s),
      v: BigInt(v),
    });

    return {
      pubkeyHex,
      r,
      s,
      v,
      e,
      signature: generatedSignature,
    };
  }
}

// helper for EllipticCoin
async function main() {
  const hash =
    "0x87f1c8cd4c0e19511304b612a9b4996f8c2bd795796636bd25812cd5b0b6a973";
  const signature =
    "0xab1dcd2a2a1c697715a62eb6522b7999d04aa952ffa2619988737ee675d9494f2b50ecce40040bcb29b5a8ca1da875968085f22b7c0a50f29a4851396251de121c";

  const out = await signatureSpoofing({ hash, signature });

  const pubkeyHex = out.pubkeyHex;
  const address = publicKeyToAddress(pubkeyHex);
  const messageHash = toHex(out.e);
  const serializedSignature = out.signature;

  console.log("publicKey:", pubkeyHex);
  console.log("address:", address); // 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e (alice)
  console.log("message hash:", messageHash);
  console.log("signature (r||s||v):", serializedSignature);
  console.log(
    "verify:",
    await verifyHash({
      hash: messageHash,
      signature: serializedSignature,
      address,
    }),
  );
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
