import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../providers/digital_id_provider.dart';

class DigitalIDScreen extends ConsumerStatefulWidget {
  const DigitalIDScreen({super.key});

  @override
  ConsumerState<DigitalIDScreen> createState() => _DigitalIDScreenState();
}

class _DigitalIDScreenState extends ConsumerState<DigitalIDScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(digitalIdProvider.notifier).fetchOrIssue();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(digitalIdProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0A1628), AppColors.background],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: AppColors.textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    Text(
                      'Digital Travel ID',
                      style: AppTypography.body
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(DigitalIdState state) {
    if (state.isLoading || state.isIssuing) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentBlue),
            ),
            const SizedBox(height: 20),
            Text(
              state.isIssuing
                  ? 'Issuing blockchain credential…\nThis may take up to 60 s'
                  : 'Loading your Digital ID…',
              textAlign: TextAlign.center,
              style: AppTypography.caption,
            ),
          ],
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: AppColors.alertRed, size: 48),
              const SizedBox(height: 16),
              Text('Could not load Digital ID',
                  style: AppTypography.h2, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(state.error!,
                  style: AppTypography.caption, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue),
                onPressed: () =>
                    ref.read(digitalIdProvider.notifier).refresh(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final data = state.data;
    if (data == null) {
      return Center(
          child: Text('No credential data.', style: AppTypography.caption));
    }

    final qrPayload = '${data.did}\n'
        'https://verify.tourist-safety.app/api/digital-id/verify/${data.credentialIdHex}/';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.accentBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified,
                    color: AppColors.accentBlue,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Ethereum Sepolia — On-Chain Verified',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.accentBlue,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          SafetyCard(
            accentColor: AppColors.accentBlue,
            child: Column(
              children: [
                Text('Scan to Verify',
                    style: AppTypography.body
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text('Show this QR at airports, hotels & check-points',
                    style: AppTypography.caption),
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: QrImageView(
                      data: qrPayload,
                      version: QrVersions.auto,
                      size: 200,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Color(0xFF0E1116),
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Color(0xFF0E1116),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SafetyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DetailRow(
                  label: 'DID',
                  value: data.did,
                  monospace: true,
                  copyable: true,
                ),
                const Divider(color: AppColors.border, height: 1),
                _DetailRow(label: 'Entry Point', value: data.entryPoint),
                const Divider(color: AppColors.border, height: 1),
                _DetailRow(
                    label: 'Issued At', value: _formatDate(data.issuedAt)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          SafetyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ON-CHAIN RECORD',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                    letterSpacing: 1.1,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),
                _DetailRow(
                  label: 'Tx Hash',
                  value: _truncateHex(data.txHash),
                  monospace: true,
                  copyable: true,
                  copyValue: data.txHash,
                ),
                const Divider(color: AppColors.border, height: 1),
                _DetailRow(
                  label: 'Data Hash',
                  value: _truncateHex(data.dataHashHex),
                  monospace: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          GestureDetector(
            onTap: () => _launchUrl(data.explorerUrl),
            child: Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.accentBlue.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.open_in_new,
                      color: AppColors.accentBlue, size: 18),
                  const SizedBox(width: 12),
                  Text(
                    'View on Sepolia Etherscan',
                    style: AppTypography.body.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                        fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }

  String _truncateHex(String hex) {
    if (hex.length <= 14) return hex;
    return '${hex.substring(0, 8)}…${hex.substring(hex.length - 6)}';
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.day} ${_month(dt.month)} ${dt.year}, '
          '${dt.hour.toString().padLeft(2, '0')}:'
          '${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _month(int m) => const [
        '',
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][m];

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool monospace;
  final bool copyable;
  final String? copyValue;

  const _DetailRow({
    required this.label,
    required this.value,
    this.monospace = false,
    this.copyable = false,
    this.copyValue,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label,
                style: AppTypography.caption.copyWith(fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: monospace
                  ? AppTypography.caption.copyWith(
                      fontFamily: 'monospace',
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    )
                  : AppTypography.body.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
          if (copyable)
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: copyValue ?? value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Copied!'),
                      duration: Duration(seconds: 1)),
                );
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.copy,
                    color: AppColors.textSecondary, size: 16),
              ),
            ),
        ],
      ),
    );
  }
}
