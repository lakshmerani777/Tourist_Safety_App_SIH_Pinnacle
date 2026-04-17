import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:share_plus/share_plus.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/status_badge.dart';
import '../providers/location_provider.dart';
import '../providers/location_sharing_provider.dart';

class LocationSharingSheet extends ConsumerWidget {
  const LocationSharingSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = ref.watch(locationProvider);
    final sharing = ref.watch(locationSharingProvider);
    final sharingNotifier = ref.read(locationSharingProvider);
    final state = sharing.state;

    final userName = 'Tourist User'; // From user profile in production

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.accentBlue.withValues(alpha: 0.15),
                    ),
                    child: const Icon(Icons.share_location, color: AppColors.accentBlue, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share Location', style: AppTypography.h2),
                        const SizedBox(height: 2),
                        Text(
                          state.isSharing ? 'Sharing is active' : 'Your location is private',
                          style: AppTypography.caption.copyWith(
                            color: state.isSharing ? AppColors.success : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (state.isSharing)
                    const StatusBadge(label: 'LIVE', type: BadgeType.active),
                ],
              ),
              const SizedBox(height: 20),

              // ─── Map Tile ───
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  height: 200,
                  child: Stack(
                    children: [
                      FlutterMap(
                        options: MapOptions(
                          initialCenter: location.currentPosition,
                          initialZoom: 15,
                          interactionOptions: const InteractionOptions(
                            flags: InteractiveFlag.none,
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.tourist_safety_app',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: location.currentPosition,
                                width: 44,
                                height: 44,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.accentBlue.withValues(alpha: 0.25),
                                    border: Border.all(color: AppColors.accentBlue, width: 2),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.person_pin, color: AppColors.accentBlue, size: 24),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Address overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.7),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.my_location, color: Colors.white, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  location.currentAddress,
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ─── Option 1: Share with Safety Authorities ───
              _SharingOptionTile(
                icon: Icons.shield_outlined,
                iconColor: AppColors.success,
                title: 'Share with Safety Authorities',
                subtitle: state.sharingWithAuthorities
                    ? 'Your location is being shared with local authorities'
                    : 'Authorities will be able to track your live location',
                isActive: state.sharingWithAuthorities,
                onToggle: () => sharingNotifier.toggleAuthoritiesSharing(
                  location.currentPosition,
                  userName,
                ),
              ),
              const SizedBox(height: 12),

              // ─── Option 2: Share with Family & Friends ───
              _SharingOptionTile(
                icon: Icons.family_restroom,
                iconColor: AppColors.accentBlue,
                title: 'Share with Family & Friends',
                subtitle: state.sharingWithFamily
                    ? 'A shareable link has been generated'
                    : 'Generate a link your family can open to see your location',
                isActive: state.sharingWithFamily,
                onToggle: () => sharingNotifier.toggleFamilySharing(
                  location.currentPosition,
                  userName,
                ),
              ),

              // ─── Link Actions ───
              if (state.sharingWithFamily && state.shareableLink != null) ...[
                const SizedBox(height: 16),
                SafetyCard(
                  accentColor: AppColors.accentBlue,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Shareable Link',
                        style: AppTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accentBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.link, color: AppColors.textSecondary, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                state.shareableLink!,
                                style: AppTypography.caption.copyWith(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.copy,
                              label: 'Copy Link',
                              color: AppColors.textPrimary,
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: state.shareableLink!));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Link copied to clipboard',
                                        style: AppTypography.caption.copyWith(color: Colors.white)),
                                    backgroundColor: AppColors.success,
                                    behavior: SnackBarBehavior.floating,
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              icon: Icons.share,
                              label: 'Share',
                              color: AppColors.accentBlue,
                              filled: true,
                              onTap: () {
                                SharePlus.instance.share(
                                  ShareParams(
                                    text: '📍 Track my live location:\n${state.shareableLink!}',
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // ─── Stop All Sharing ───
              if (state.isSharing)
                GestureDetector(
                  onTap: () {
                    sharingNotifier.stopAllSharing();
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.alertRed.withValues(alpha: 0.5)),
                      color: AppColors.alertRed.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stop_circle_outlined, color: AppColors.alertRed, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Stop All Sharing',
                          style: AppTypography.body.copyWith(
                            color: AppColors.alertRed,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Sharing Option Tile ───
class _SharingOptionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback onToggle;

  const _SharingOptionTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return SafetyCard(
      accentColor: isActive ? iconColor : null,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: iconColor.withValues(alpha: isActive ? 0.2 : 0.1),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTypography.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch.adaptive(
            value: isActive,
            onChanged: (_) => onToggle(),
            activeColor: iconColor,
          ),
        ],
      ),
    );
  }
}

// ─── Small Action Button ───
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: filled ? color.withValues(alpha: 0.15) : AppColors.card,
          border: Border.all(color: filled ? color.withValues(alpha: 0.4) : AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? color : AppColors.textSecondary, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                color: filled ? color : AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
