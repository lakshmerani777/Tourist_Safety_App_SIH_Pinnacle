# Blockchain Interview / Exam Questions & Answers

---

## 1. Generic Blockchain Fundamentals

**Q1. What is a blockchain?**
> A blockchain is a distributed, append-only ledger of records (blocks) linked together via cryptographic hashes. Each block contains a hash of the previous block, a timestamp, and transaction data. Because every participant holds a copy and consensus rules govern additions, tampering with any block invalidates all subsequent blocks.

---

**Q2. What is the difference between a public, private, and consortium blockchain?**
| Type | Access | Validators | Examples |
|------|--------|-----------|---------|
| Public | Anyone | Anyone | Bitcoin, Ethereum |
| Private | Permissioned (one org) | Chosen nodes | Hyperledger Fabric (enterprise) |
| Consortium | Permissioned (group of orgs) | Member nodes | R3 Corda, Quorum |

---

**Q3. What is a hash function and why is it important in blockchain?**
> A hash function maps arbitrary input to a fixed-size digest deterministically. Properties critical to blockchain:
> - **Pre-image resistance** — you can't reverse-engineer input from output.
> - **Collision resistance** — two different inputs should not produce the same hash.
> - **Avalanche effect** — a tiny input change completely alters the output.
>
> Bitcoin uses SHA-256; Ethereum uses Keccak-256. Hashes link blocks and secure transaction IDs.

---

**Q4. What is a Merkle Tree and how does it relate to blockchain?**
> A Merkle Tree is a binary hash tree where leaf nodes are hashes of individual transactions and parent nodes are hashes of their children. The **Merkle Root** (stored in the block header) lets light clients verify whether a transaction is in a block with O(log n) proof instead of downloading every transaction.

---

**Q5. Explain Proof of Work (PoW) vs Proof of Stake (PoS).**
| | PoW | PoS |
|--|-----|-----|
| Mechanism | Miners race to solve SHA-256 puzzle | Validators stake coins as collateral |
| Energy | Very high | Low |
| Security model | 51% hash-rate attack | 51% stake attack |
| Examples | Bitcoin | Ethereum (post-Merge), Cardano |
| Reward | Block reward + fees | Staking yield + fees |

---

**Q6. What is a 51% attack?**
> If a single entity controls more than 50% of the network's mining power (PoW) or staked tokens (PoS), it can rewrite recent blocks, double-spend coins, or censor transactions. It cannot forge signatures or steal funds from unrelated wallets.

---

**Q7. What is a smart contract?**
> A smart contract is self-executing code deployed on a blockchain. When predefined conditions are met, the contract executes automatically without an intermediary. Ethereum smart contracts are written in Solidity and run on the Ethereum Virtual Machine (EVM). They are immutable once deployed (unless using proxy/upgrade patterns).

---

**Q8. What is the difference between a coin and a token?**
> - **Coin** — native currency of its own blockchain (ETH on Ethereum, BTC on Bitcoin).
> - **Token** — built on top of an existing blockchain via a smart contract (ERC-20, ERC-721). Tokens represent assets, voting rights, or utility within a dApp.

---

**Q9. What is gas in Ethereum?**
> Gas is the unit measuring computational effort. Each EVM opcode has a fixed gas cost. Users pay `gas_used × gas_price` in ETH. Gas limits prevent infinite loops and denial-of-service on the network. Post-EIP-1559, fees split into a **base fee** (burned) and a **priority tip** (to validator).

---

**Q10. What are ERC-20 and ERC-721 standards?**
> - **ERC-20** — fungible token standard; every token is identical and interchangeable (USDC, LINK).
> - **ERC-721** — non-fungible token (NFT) standard; every token has a unique `tokenId` and represents a distinct asset.
> - **ERC-1155** — multi-token standard supporting both fungible and non-fungible tokens in one contract.

---

## 2. Consensus & Architecture

**Q11. What is Byzantine Fault Tolerance (BFT)?**
> A system is BFT if it can reach consensus even when up to `f` nodes act arbitrarily maliciously, given `n ≥ 3f + 1` total nodes. Practical BFT (pBFT) is used in permissioned chains. Ethereum's PoS uses Casper FFG, a BFT-based finality gadget.

---

**Q12. What is the CAP theorem and how does it apply to blockchain?**
> The CAP theorem states a distributed system can only guarantee two of: **Consistency**, **Availability**, **Partition Tolerance**. Most blockchains prioritize **Consistency + Partition Tolerance** (CP) — nodes may temporarily be unavailable during a fork but will always converge on one canonical chain.

---

**Q13. What is a fork (hard fork vs soft fork)?**
> - **Hard fork** — backward-incompatible rule change; non-upgraded nodes reject new blocks. Creates a permanent chain split if not unanimous (e.g., ETH/ETC split).
> - **Soft fork** — backward-compatible tightening of rules; old nodes still accept new blocks (e.g., Bitcoin SegWit).

---

**Q14. What is sharding?**
> Sharding horizontally partitions the blockchain state into smaller pieces (shards), each processed by a subset of validators. This increases throughput (TPS) without every node processing every transaction. Ethereum's roadmap includes danksharding for data availability scaling.

---

**Q15. What are Layer 2 solutions?**
> L2 solutions process transactions off the main chain (L1) and periodically post proofs or summaries back. Types:
> - **State Channels** — off-chain bilateral channels (Lightning Network).
> - **Rollups** — batch transactions, post compressed data to L1.
>   - *Optimistic Rollups* — assume valid; fraud proofs during challenge period (Arbitrum, Optimism).
>   - *ZK-Rollups* — post validity proof; instant finality (zkSync, StarkNet).

---

## 3. Security & Cryptography

**Q16. What is a digital signature and how does it work in blockchain?**
> Blockchain uses **ECDSA** (Elliptic Curve Digital Signature Algorithm). A user's private key signs a transaction hash producing `(r, s)`. Anyone with the public key can verify the signature without knowing the private key. This proves authenticity and non-repudiation.

---

**Q17. What is a double-spend attack?**
> An attacker sends the same funds to two recipients simultaneously, attempting to make both accept the payment. PoW prevents this via longest-chain rule; a merchant should wait for sufficient confirmations (typically 6 blocks for Bitcoin) before considering a transaction final.

---

**Q18. What are common smart contract vulnerabilities?**
> - **Reentrancy** — malicious contract calls back into the victim before state updates (The DAO hack). Fix: checks-effects-interactions pattern or `ReentrancyGuard`.
> - **Integer overflow/underflow** — Solidity <0.8 had no built-in checks. Fix: use SafeMath or Solidity ≥0.8.
> - **Front-running** — miners (or searchers) reorder transactions for profit. Fix: commit-reveal schemes.
> - **Access control flaws** — missing `onlyOwner` or role checks.
> - **Oracle manipulation** — flash loans inflating on-chain price feeds.

---

**Q19. What is a flash loan attack?**
> Flash loans are uncollateralized loans that must be borrowed and repaid within a single transaction. Attackers borrow massive capital, manipulate oracle prices or governance, profit, and repay — all atomically. If repayment fails, the entire transaction reverts.

---

**Q20. What is zero-knowledge proof (ZKP)?**
> A ZKP allows one party (prover) to convince another (verifier) that a statement is true without revealing any information beyond the truth of the statement. Used in privacy coins (Zcash uses zk-SNARKs) and ZK-Rollups for scalable, private verification.

---

## 4. DeFi & dApps

**Q21. What is DeFi?**
> Decentralized Finance — financial services (lending, borrowing, trading, yield farming) built on public blockchains using smart contracts, removing traditional intermediaries. Key protocols: Uniswap (DEX), Aave (lending), MakerDAO (stablecoin).

---

**Q22. How does an Automated Market Maker (AMM) work?**
> An AMM replaces the order book with a liquidity pool and a pricing formula. Uniswap uses **x × y = k** (constant product). When a trader swaps token A for B, x increases and y decreases to maintain k, adjusting price automatically. Liquidity providers earn fees proportional to their pool share.

---

**Q23. What is impermanent loss?**
> When the price ratio of tokens in a liquidity pool changes from deposit time, LPs end up with a different asset mix than if they had simply held. The loss is "impermanent" because it disappears if prices revert, but is locked in on withdrawal.

---

**Q24. What is a DAO?**
> A Decentralized Autonomous Organization is an entity governed entirely by smart contracts and token-holder votes, with no central management. Proposals are submitted on-chain; token holders vote; passed proposals execute automatically.

---

## 5. Ethereum & Solidity Specifics

**Q25. What is the EVM?**
> The Ethereum Virtual Machine is a stack-based, sandboxed runtime that executes smart contract bytecode. It is deterministic across all nodes, enabling consensus. It exposes 256-bit word operations, memory, storage, and a call stack.

---

**Q26. Explain the storage layout in Solidity.**
> Each contract has 2²⁵⁶ storage slots (32 bytes each). State variables are packed into slots in declaration order. Mappings and dynamic arrays use `keccak256` of the slot and key as their storage location. Understanding this is critical for upgradeable proxies and gas optimization.

---

**Q27. What is the difference between `memory`, `storage`, and `calldata` in Solidity?**
> - `storage` — persists on-chain; expensive (SSTORE ~20,000 gas).
> - `memory` — temporary, per-call; cheap.
> - `calldata` — read-only input data from the transaction; cheapest for function parameters.

---

**Q28. What is a proxy contract / upgradeable contract pattern?**
> Since deployed bytecode is immutable, an upgradeable pattern splits logic and storage:
> - **Proxy** holds state and delegates all calls via `delegatecall` to the **Implementation** contract.
> - To upgrade, point the proxy to a new implementation address.
> - Patterns: Transparent Proxy (OpenZeppelin), UUPS (EIP-1822), Beacon Proxy.

---

**Q29. What is `delegatecall` and why is it dangerous?**
> `delegatecall` executes another contract's code in the caller's storage context. The implementation contract can read/write the proxy's storage. If storage layouts don't match or the implementation has a selfdestruct, it can brick the proxy or drain funds.

---

**Q30. What is EIP-1559 and how did it change Ethereum fees?**
> EIP-1559 (London hard fork, Aug 2021) introduced a **base fee** algorithmically adjusted per block targeting 50% capacity, plus an optional **priority tip** to incentivize validators. The base fee is burned (deflationary), making ETH potentially deflationary during high usage. Users set a `maxFeePerGas` cap.

---

## 6. Quick-Fire Concepts

| Term | One-liner |
|------|-----------|
| UTXO | Unspent Transaction Output model (Bitcoin) — outputs are consumed whole and change is returned |
| Nonce | In PoW: a number miners iterate to find a valid block hash. In Ethereum accounts: sequential tx counter preventing replay |
| Mempool | Pool of unconfirmed transactions waiting to be included in a block |
| Finality | The point after which a transaction cannot be reversed |
| Tokenomics | Economic design of a token: supply schedule, inflation, incentives |
| Oracle | Bridge bringing off-chain data (prices, weather) on-chain (Chainlink) |
| Sybil attack | Creating many fake identities to gain disproportionate influence |
| Slashing | Penalty burning a validator's staked tokens for misbehavior (PoS) |
| MEV | Maximal Extractable Value — profit miners/validators extract by reordering/inserting txs |
| ABI | Application Binary Interface — defines how to encode/decode calls to a smart contract |

---

## 7. Likely Professor "Gotcha" Questions

**Q: If blockchain is immutable, how do you fix bugs in smart contracts?**
> You can't modify deployed code. Solutions: deploy a new contract + migrate users, use proxy upgrade patterns, or include an emergency pause mechanism via `Pausable`.

---

**Q: Is blockchain a database? How is it different?**
> Blockchain is an append-only distributed ledger, not a general-purpose database. It lacks efficient queries, updates, or deletes. It trades performance for trustlessness and auditability. Traditional DBs (ACID) are faster and mutable but require trusted administrators.

---

**Q: Why can't smart contracts call external APIs directly?**
> Because all nodes must replay transactions and reach identical state. An HTTP call would return different results at different times, breaking determinism. External data must come through a trusted oracle network (Chainlink) that posts data on-chain first.

---

**Q: What happens if two miners find a valid block simultaneously?**
> A temporary fork occurs. Both branches are propagated; nodes follow the longest-chain rule. When one branch grows longer (next block found on it), the other is orphaned and those transactions return to the mempool.

---

**Q: Can you delete data from a blockchain?**
> No — blocks are permanent. However, GDPR compliance strategies include storing only a hash on-chain with personal data off-chain (allowing off-chain deletion while the hash remains). Some chains implement pruning of old state, but the hash chain remains intact.

---

*Good luck!*
