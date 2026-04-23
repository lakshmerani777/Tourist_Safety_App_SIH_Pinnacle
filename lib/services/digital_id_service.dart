class DigitalIdData {
  final String did;
  final String credentialIdHex;
  final String dataHashHex;
  final String txHash;
  final String issuedAt;
  final String entryPoint;
  final String explorerUrl;
  final bool alreadyIssued;

  const DigitalIdData({
    required this.did,
    required this.credentialIdHex,
    required this.dataHashHex,
    required this.txHash,
    required this.issuedAt,
    required this.entryPoint,
    required this.explorerUrl,
    this.alreadyIssued = false,
  });

  factory DigitalIdData.fromJson(Map<String, dynamic> j) => DigitalIdData(
        did:             j['did']               as String? ?? '',
        credentialIdHex: j['credential_id_hex'] as String? ?? '',
        dataHashHex:     j['data_hash_hex']     as String? ?? '',
        txHash:          j['tx_hash']           as String? ?? '',
        issuedAt:        j['issued_at']         as String? ?? '',
        entryPoint:      j['entry_point']       as String? ?? '',
        explorerUrl:     j['explorer_url']      as String? ?? '',
        alreadyIssued:   j['already_issued']    as bool?   ?? false,
      );
}

class VerificationResult {
  final bool isValid;
  final bool chainVerified;
  final String did;
  final String issuedAt;
  final String entryPoint;
  final String explorerUrl;
  final bool? hashesMatch;
  final String? issuedBy;

  const VerificationResult({
    required this.isValid,
    required this.chainVerified,
    required this.did,
    required this.issuedAt,
    required this.entryPoint,
    required this.explorerUrl,
    this.hashesMatch,
    this.issuedBy,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> j) =>
      VerificationResult(
        isValid:       j['is_valid']       as bool?   ?? false,
        chainVerified: j['chain_verified'] as bool?   ?? false,
        did:           j['did']            as String? ?? '',
        issuedAt:      j['issued_at']      as String? ?? '',
        entryPoint:    j['entry_point']    as String? ?? '',
        explorerUrl:   j['explorer_url']   as String? ?? '',
        hashesMatch:   j['hashes_match']   as bool?,
        issuedBy:      j['issued_by']      as String?,
      );
}
