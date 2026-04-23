// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * TouristCredentialRegistry
 *
 * Issues tamper-proof digital ID credentials for tourists on Ethereum Sepolia.
 * Only the deployer (backend issuer wallet) can issue or revoke credentials.
 *
 * Credential IDs and data hashes are computed off-chain by the Django backend:
 *   credentialId = keccak256(abi.encodePacked(userId, ":", issuedAtUnix))
 *   dataHash     = SHA-256(name|nationality|passportHash|entryPoint|issuedAt)
 *
 * Raw PII never appears on-chain — only keccak/SHA-256 digests.
 */
contract TouristCredentialRegistry {

    struct Credential {
        bytes32 credentialId;
        bytes32 dataHash;
        uint256 issuedAt;
        address issuedBy;
        bool    isRevoked;
    }

    address public owner;

    mapping(bytes32 => Credential) private _credentials;

    event CredentialIssued(
        bytes32 indexed credentialId,
        bytes32 dataHash,
        uint256 issuedAt,
        address indexed issuedBy
    );

    event CredentialRevoked(
        bytes32 indexed credentialId,
        uint256 revokedAt
    );

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * Issue a credential. Reverts if credentialId already exists.
     * @param credentialId  keccak256(userId:issuedAtUnix) — computed off-chain
     * @param dataHash      SHA-256 of PII bundle — computed off-chain
     */
    function issueCredential(bytes32 credentialId, bytes32 dataHash) external onlyOwner {
        require(_credentials[credentialId].issuedAt == 0, "Already issued");

        _credentials[credentialId] = Credential({
            credentialId: credentialId,
            dataHash:     dataHash,
            issuedAt:     block.timestamp,
            issuedBy:     msg.sender,
            isRevoked:    false
        });

        emit CredentialIssued(credentialId, dataHash, block.timestamp, msg.sender);
    }

    /**
     * Verify a credential. Returns isValid=true only if it exists and is not revoked.
     */
    function verifyCredential(bytes32 credentialId)
        external
        view
        returns (
            bool    isValid,
            bytes32 dataHash,
            uint256 issuedAt,
            address issuedBy
        )
    {
        Credential memory c = _credentials[credentialId];
        isValid  = (c.issuedAt != 0 && !c.isRevoked);
        dataHash = c.dataHash;
        issuedAt = c.issuedAt;
        issuedBy = c.issuedBy;
    }

    /**
     * Revoke a credential (e.g. on passport expiry or fraud).
     * The on-chain record is preserved with isRevoked=true for audit trail.
     */
    function revokeCredential(bytes32 credentialId) external onlyOwner {
        require(_credentials[credentialId].issuedAt != 0, "Not found");
        _credentials[credentialId].isRevoked = true;
        emit CredentialRevoked(credentialId, block.timestamp);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        owner = newOwner;
    }
}
