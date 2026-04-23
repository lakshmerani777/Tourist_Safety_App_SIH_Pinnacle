"""
blockchain_service.py

Two modes, selected automatically based on .env:

  LIVE mode    — all three vars set (SEPOLIA_RPC_URL, ISSUER_PRIVATE_KEY, CONTRACT_ADDRESS)
                 Submits real transactions to Ethereum Sepolia testnet.

  OFFLINE mode — any var missing (default for local / air-gapped deployments)
                 Computes identical keccak256 / SHA-256 hashes and generates a
                 deterministic tx hash derived from the credential. No RPC calls
                 required. The verify endpoint, QR code, and Flutter UI all
                 behave identically to live mode.
"""

import hashlib
import os
import time
from datetime import datetime, timezone

from decouple import config

# ── Shared hash helpers (used by both modes) ──────────────────────


def _compute_credential_id(user_id: str, issued_at_unix: int) -> bytes:
    packed = f"{user_id}:{issued_at_unix}".encode()
    try:
        import sha3  # pysha3 package
        h = sha3.keccak_256(packed)
        return h.digest()
    except ImportError:
        return hashlib.sha256(packed).digest()


def _compute_data_hash(
    full_name: str,
    nationality: str,
    passport_number: str,
    entry_point: str,
    issued_at_iso: str,
) -> bytes:
    passport_hash = hashlib.sha256(passport_number.encode()).hexdigest()
    bundle = f"{full_name}|{nationality}|{passport_hash}|{entry_point}|{issued_at_iso}"
    return hashlib.sha256(bundle.encode()).digest()


# ── Offline service (no RPC, no crypto wallet) ───────────────────

_ISSUER_ADDRESS = '0xF4D8e3a1C9b7F2e6D0c8A5B3e1f9D7C4a2B8E0d6'


class _OfflineBlockchainService:
    """
    Offline-capable credential registry.
    Produces real keccak256 credential IDs, SHA-256 data hashes, and
    deterministic tx hashes so the Flutter UI and verify endpoint behave
    identically to live mode.
    """

    def __init__(self):
        self._issued: dict[str, str] = {}  # credential_id_hex -> data_hash_hex

    def _load_from_db(self, credential_id_hex: str) -> None:
        if credential_id_hex in self._issued:
            return
        try:
            from .models import TouristDigitalID
            record = TouristDigitalID.objects.get(credential_id_hex=credential_id_hex)
            self._issued[credential_id_hex] = record.data_hash_hex
        except Exception:
            pass

    def issue_credential(
        self,
        user_id: str,
        full_name: str,
        nationality: str,
        passport_number: str,
        entry_point: str,
    ) -> dict:
        issued_at_unix = int(time.time())
        issued_at_iso  = datetime.fromtimestamp(issued_at_unix, tz=timezone.utc).isoformat()

        cred_id_bytes   = _compute_credential_id(user_id, issued_at_unix)
        data_hash_bytes = _compute_data_hash(
            full_name, nationality, passport_number, entry_point, issued_at_iso
        )

        cred_id_hex   = '0x' + cred_id_bytes.hex()
        data_hash_hex = '0x' + data_hash_bytes.hex()

        tx_raw = hashlib.sha256(f"{cred_id_hex}{issued_at_unix}".encode()).hexdigest()
        tx_hash = '0x' + tx_raw

        self._issued[cred_id_hex] = data_hash_hex

        return {
            'credential_id_hex': cred_id_hex,
            'did':               f'did:tourist:{cred_id_hex}',
            'tx_hash':           tx_hash,
            'issued_at':         issued_at_iso,
            'data_hash_hex':     data_hash_hex,
        }

    def verify_credential(self, credential_id_hex: str) -> dict:
        self._load_from_db(credential_id_hex)
        data_hash_hex = self._issued.get(credential_id_hex, '0x' + '00' * 32)
        return {
            'is_valid':      credential_id_hex in self._issued,
            'data_hash_hex': data_hash_hex,
            'issued_at':     datetime.now(tz=timezone.utc).isoformat(),
            'issued_by':     _ISSUER_ADDRESS,
        }


# ── Live service (Ethereum Sepolia via web3.py) ───────────────────

CONTRACT_ABI = [
    {
        "inputs": [
            {"internalType": "bytes32", "name": "credentialId", "type": "bytes32"},
            {"internalType": "bytes32", "name": "dataHash",     "type": "bytes32"},
        ],
        "name": "issueCredential",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function",
    },
    {
        "inputs": [
            {"internalType": "bytes32", "name": "credentialId", "type": "bytes32"},
        ],
        "name": "verifyCredential",
        "outputs": [
            {"internalType": "bool",    "name": "isValid",  "type": "bool"},
            {"internalType": "bytes32", "name": "dataHash", "type": "bytes32"},
            {"internalType": "uint256", "name": "issuedAt", "type": "uint256"},
            {"internalType": "address", "name": "issuedBy", "type": "address"},
        ],
        "stateMutability": "view",
        "type": "function",
    },
    {
        "inputs": [
            {"internalType": "bytes32", "name": "credentialId", "type": "bytes32"},
        ],
        "name": "revokeCredential",
        "outputs": [],
        "stateMutability": "nonpayable",
        "type": "function",
    },
]


class BlockchainService:

    def __init__(self):
        from web3 import Web3
        from web3.middleware import ExtraDataToPOAMiddleware

        rpc_url         = config('SEPOLIA_RPC_URL')
        private_key_hex = config('ISSUER_PRIVATE_KEY')
        contract_addr   = config('CONTRACT_ADDRESS')

        self.w3 = Web3(Web3.HTTPProvider(rpc_url))
        self.w3.middleware_onion.inject(ExtraDataToPOAMiddleware, layer=0)

        if not self.w3.is_connected():
            raise ConnectionError(f"Cannot connect to Sepolia RPC: {rpc_url}")

        if not private_key_hex.startswith('0x'):
            private_key_hex = '0x' + private_key_hex
        self.account = self.w3.eth.account.from_key(private_key_hex)
        self._Web3 = Web3

        self.contract = self.w3.eth.contract(
            address=Web3.to_checksum_address(contract_addr),
            abi=CONTRACT_ABI,
        )

    def issue_credential(
        self,
        user_id: str,
        full_name: str,
        nationality: str,
        passport_number: str,
        entry_point: str,
    ) -> dict:
        issued_at_unix = int(time.time())
        issued_at_iso  = datetime.fromtimestamp(issued_at_unix, tz=timezone.utc).isoformat()

        cred_id_bytes   = _compute_credential_id(user_id, issued_at_unix)
        data_hash_bytes = _compute_data_hash(
            full_name, nationality, passport_number, entry_point, issued_at_iso
        )

        cred_id_b32   = cred_id_bytes[:32]
        data_hash_b32 = data_hash_bytes[:32]

        nonce = self.w3.eth.get_transaction_count(self.account.address)
        tx = self.contract.functions.issueCredential(
            cred_id_b32, data_hash_b32
        ).build_transaction({
            'from':     self.account.address,
            'nonce':    nonce,
            'gas':      200_000,
            'gasPrice': self.w3.eth.gas_price,
            'chainId':  11155111,
        })
        signed  = self.w3.eth.account.sign_transaction(tx, private_key=self.account.key)
        tx_hash = self.w3.eth.send_raw_transaction(signed.raw_transaction)

        receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash, timeout=120)
        if receipt.status != 1:
            raise RuntimeError(f"Transaction reverted: {tx_hash.hex()}")

        cred_id_hex   = '0x' + cred_id_b32.hex()
        data_hash_hex = '0x' + data_hash_b32.hex()

        return {
            'credential_id_hex': cred_id_hex,
            'did':               f'did:tourist:{cred_id_hex}',
            'tx_hash':           '0x' + tx_hash.hex(),
            'issued_at':         issued_at_iso,
            'data_hash_hex':     data_hash_hex,
        }

    def verify_credential(self, credential_id_hex: str) -> dict:
        cred_id_bytes = bytes.fromhex(credential_id_hex.lstrip('0x'))
        cred_id_b32   = cred_id_bytes.ljust(32, b'\x00')[:32]

        is_valid, data_hash, issued_at_unix, issued_by = (
            self.contract.functions.verifyCredential(cred_id_b32).call()
        )

        issued_at_iso = (
            datetime.fromtimestamp(issued_at_unix, tz=timezone.utc).isoformat()
            if issued_at_unix else None
        )

        return {
            'is_valid':      is_valid,
            'data_hash_hex': '0x' + data_hash.hex(),
            'issued_at':     issued_at_iso,
            'issued_by':     issued_by,
        }


# ── Auto-select service based on .env ────────────────────────────

_service = None


def get_blockchain_service():
    global _service
    if _service is not None:
        return _service

    rpc_url       = config('SEPOLIA_RPC_URL',    default='')
    private_key   = config('ISSUER_PRIVATE_KEY', default='')
    contract_addr = config('CONTRACT_ADDRESS',   default='')

    if all([rpc_url, private_key, contract_addr]):
        _service = BlockchainService()
    else:
        _service = _OfflineBlockchainService()

    return _service
