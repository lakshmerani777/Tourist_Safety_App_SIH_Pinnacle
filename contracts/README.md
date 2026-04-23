# Blockchain Digital ID — Setup Guide

## Overview

`TouristCredentialRegistry.sol` is deployed on **Ethereum Sepolia testnet**. The Django backend
uses it to issue tamper-proof digital IDs to tourists after onboarding.

---

## Step 1 — Generate an Issuer Wallet

Run this once. Save the output somewhere safe.

```bash
python -c "from eth_account import Account; a=Account.create(); print('Address:', a.address); print('Private key:', a.key.hex())"
```

The **address** is your issuer wallet. The **private key** goes into `.env`.

---

## Step 2 — Get Free Test ETH

1. Copy your wallet address from Step 1
2. Go to https://sepoliafaucet.com (or https://faucet.sepolia.dev)
3. Paste the address and request test ETH
4. 0.5 ETH is enough for thousands of credential issuances

---

## Step 3 — Get a Sepolia RPC URL

**Option A — Infura (recommended):**
1. Create a free account at https://app.infura.io
2. Create a new project → select Ethereum → Sepolia
3. Copy the HTTPS endpoint: `https://sepolia.infura.io/v3/YOUR_PROJECT_ID`

**Option B — Alchemy:**
1. Create a free account at https://dashboard.alchemy.com
2. Create app → Ethereum → Sepolia
3. Copy the HTTPS endpoint: `https://eth-sepolia.g.alchemy.com/v2/YOUR_API_KEY`

---

## Step 4 — Deploy the Contract (Remix IDE — no toolchain needed)

1. Go to https://remix.ethereum.org
2. In the **File Explorer**, create a new file: `TouristCredentialRegistry.sol`
3. Paste the contents of `contracts/TouristCredentialRegistry.sol` from this repo
4. Click the **Solidity Compiler** tab (left sidebar)
   - Compiler version: `0.8.20`
   - Enable optimization: ✓ (200 runs)
   - Click **Compile**
5. Click the **Deploy & Run Transactions** tab
   - Environment: **Injected Provider - MetaMask**
   - Switch MetaMask to **Sepolia testnet**
   - Contract: `TouristCredentialRegistry`
   - Click **Deploy** → confirm in MetaMask
6. After deployment, copy the contract address from the **Deployed Contracts** panel (starts with `0x`)

---

## Step 5 — Configure `.env`

Open `backend/PinnacleBackend/.env` and add these three lines:

```
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_PROJECT_ID
ISSUER_PRIVATE_KEY=your64hexcharprivatekey
CONTRACT_ADDRESS=0xYourDeployedContractAddress
```

> **Important:** `ISSUER_PRIVATE_KEY` must be the private key of the wallet you funded in Step 2.
> Do NOT include the `0x` prefix.

---

## Step 6 — Run Migrations

```bash
cd backend/PinnacleBackend
source venv/bin/activate
python manage.py migrate
```

---

## Verifying It Works

After a tourist completes onboarding, check:

```bash
# Django should log no errors for _auto_issue_credential
# Then test the verify endpoint:
curl http://localhost:8000/api/digital-id/me/ -H "X-Session-Id: YOUR_SESSION_ID"
```

Expected response:
```json
{
  "did": "did:tourist:0x...",
  "credential_id_hex": "0x...",
  "tx_hash": "0x...",
  "issued_at": "2026-04-23T...",
  "entry_point": "app_onboarding",
  "explorer_url": "https://sepolia.etherscan.io/tx/0x..."
}
```

Open `explorer_url` in a browser to see the transaction on Sepolia Etherscan.

---

## API Endpoints Added

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/api/digital-id/issue/` | Session | Issue or return existing credential |
| `GET`  | `/api/digital-id/me/` | Session | Get your digital ID |
| `GET`  | `/api/digital-id/verify/<id>/` | None | Public — verify by credential ID (QR scan) |

---

## How the QR Code Works

The QR in the Flutter app encodes:
```
did:tourist:0x<credentialId>
https://<your-backend>/api/digital-id/verify/0x<credentialId>/
```

Police at check-points scan this QR → hits the public verify endpoint →
cross-checks the on-chain record → returns `is_valid: true/false`.

---

## Credential Security Model

- **Raw PII never stored on-chain** — only a SHA-256 hash of `(name|nationality|passportHash|entryPoint|issuedAt)`
- **Passport number is itself hashed** before being included in the bundle
- **`onlyOwner`** modifier ensures only the backend wallet can issue or revoke credentials
- **`chainId=11155111`** guard in the backend prevents the signed transaction from being replayed on mainnet
- Credentials are **revocable** (sets `isRevoked=true`) but the audit trail is permanently preserved on-chain
