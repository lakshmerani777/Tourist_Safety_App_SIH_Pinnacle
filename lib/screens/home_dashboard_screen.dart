import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/status_badge.dart';
import '../core/router/app_router.dart';
import '../widgets/chatbot_overlay.dart';
import '../providers/location_provider.dart';
import '../services/widget_service.dart';
import '../l10n/app_localizations.dart';
import 'location_sharing_sheet.dart';

class HomeDashboardScreen extends ConsumerStatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  ConsumerState<HomeDashboardScreen> createState() =>
      _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends ConsumerState<HomeDashboardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationProvider).fetchCurrentLocation();
    });
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetService.init(appRouter);
    WidgetService.updateSafetyStatus(isProtected: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _openChatbot() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 1,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: const ChatbotOverlay(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 1:
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) context.push('/map');
          setState(() => _selectedIndex = 0);
        });
        return _buildHomeContent();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context)?.appTitle ?? 'Tourist Safety',
                      style: AppTypography.h2,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  StatusBadge(
                    label: AppLocalizations.of(context)?.protectedStatus ?? 'Protected',
                    type: BadgeType.active,
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context.push('/profile'),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.card,
                        border: Border.all(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.person_outline,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Location Banner
          Consumer(
            builder: (context, ref, _) {
              final location = ref.watch(locationProvider);
              return GestureDetector(
                onTap: () => context.push('/map'),
                child: SafetyCard(
                  accentColor: AppColors.accentBlue,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.accentBlue.withValues(alpha: 0.15),
                        ),
                        child: location.isLoading
                            ? const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation(AppColors.accentBlue),
                                ),
                              )
                            : const Icon(Icons.my_location, color: AppColors.accentBlue, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)?.currentLocation ?? 'Current Location',
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.accentBlue,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              location.currentAddress,
                              style: AppTypography.body.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),

          // Safety Status Card
          SafetyCard(
            accentColor: AppColors.success,
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 18,
                            height: 18,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (AppLocalizations.of(context)?.protectedStatus ?? 'Protected').toUpperCase(),
                        style: AppTypography.body.copyWith(
                          color: AppColors.success,
                          letterSpacing: 1.2,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)?.lastUpdatedNow ?? 'Last updated: Just now',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // SOS Button — prominent, above quick actions
          Center(
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    HapticFeedback.heavyImpact();
                    context.push('/sos');
                  },
                  child: AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow ring
                          Transform.scale(
                            scale: _pulseAnimation.value,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.alertRed.withValues(alpha: 0.08),
                              ),
                            ),
                          ),
                          // Mid ring
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.alertRed.withValues(alpha: 0.15),
                            ),
                          ),
                          // Core button
                          Transform.scale(
                            scale: _pulseAnimation.value * 0.95,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.alertRed,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x55FF3B3B),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)?.sosText ?? 'SOS',
                                  style: AppTypography.h1.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 22,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap to send emergency alert',
                  style: AppTypography.caption.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Quick Actions
          Text(AppLocalizations.of(context)?.quickActions ?? 'Quick Actions', style: AppTypography.h2),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _QuickActionCard(
                title: AppLocalizations.of(context)?.reportIncident ?? 'Report\nIncident',
                icon: Icons.report_problem_outlined,
                color: AppColors.warning,
                onTap: () => context.push('/report'),
              ),
              _QuickActionCard(
                title: AppLocalizations.of(context)?.shareLocation ?? 'Share\nLocation',
                icon: Icons.share_location,
                color: AppColors.accentBlue,
                onTap: () {
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (ctx) => DraggableScrollableSheet(
                      initialChildSize: 0.8,
                      minChildSize: 0.5,
                      maxChildSize: 0.95,
                      expand: false,
                      builder: (_, scrollController) => const LocationSharingSheet(),
                    ),
                  );
                },
              ),
              _QuickActionCard(
                title: AppLocalizations.of(context)?.emergencyContacts ?? 'Emergency\nContacts',
                icon: Icons.phone_in_talk,
                color: AppColors.alertRed,
                onTap: () => context.push('/emergency'),
              ),
              _QuickActionCard(
                title: AppLocalizations.of(context)?.safetyMap ?? 'Safety\nMap',
                icon: Icons.map_outlined,
                color: AppColors.accentBlue,
                onTap: () => context.push('/map'),
              ),
              _QuickActionCard(
                title: 'Digital\nID',
                icon: Icons.verified_user_outlined,
                color: AppColors.accentBlue,
                onTap: () => context.push('/digital-id'),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Recent Alerts
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  AppLocalizations.of(context)?.recentAlerts ?? 'Recent Alerts',
                  style: AppTypography.h2,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/alerts'),
                child: Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)?.viewAll ?? 'View All',
                      style: AppTypography.body.copyWith(
                        color: AppColors.accentBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: AppColors.accentBlue, size: 20),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _AlertItem(
            title: 'Weather Advisory',
            subtitle: 'Heavy rainfall expected in your area',
            badge: const StatusBadge(label: 'Warning', type: BadgeType.warning),
            time: '2 hours ago',
          ),
          const SizedBox(height: 12),
          _AlertItem(
            title: 'Travel Update',
            subtitle: 'Road closure on NH-44 near Jaipur',
            badge: const StatusBadge(label: 'Alert', type: BadgeType.alert),
            time: '5 hours ago',
          ),
          const SizedBox(height: 12),
          _AlertItem(
            title: 'Safety Check',
            subtitle: 'Routine safety check completed',
            badge: const StatusBadge(label: 'Active', type: BadgeType.active),
            time: '1 day ago',
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 0.5),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == 1) {
            context.push('/map');
          } else if (index == 2) {
            _openChatbot();
          } else if (index == 3) {
            context.push('/alerts');
          } else if (index == 4) {
            context.push('/profile');
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            activeIcon: const Icon(Icons.home),
            label: AppLocalizations.of(context)?.navHome ?? 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map_outlined),
            activeIcon: const Icon(Icons.map),
            label: AppLocalizations.of(context)?.navMap ?? 'Map',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            activeIcon: const Icon(Icons.chat_bubble_rounded),
            label: AppLocalizations.of(context)?.navChat ?? 'Chat',
          ),
          BottomNavigationBarItem(
            icon: const Badge(
              backgroundColor: AppColors.alertRed,
              smallSize: 8,
              child: Icon(Icons.notifications_outlined),
            ),
            activeIcon: const Badge(
              backgroundColor: AppColors.alertRed,
              smallSize: 8,
              child: Icon(Icons.notifications),
            ),
            label: AppLocalizations.of(context)?.navAlerts ?? 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            activeIcon: const Icon(Icons.person),
            label: AppLocalizations.of(context)?.navProfile ?? 'Profile',
          ),
        ],
      ),
    );
  }
}

// -- Quick Action Card --
class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: color.withValues(alpha: 0.15),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            Flexible(
              child: Text(
                title,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -- Alert Item --
class _AlertItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget badge;
  final String time;

  const _AlertItem({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return SafetyCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    badge,
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: AppTypography.body.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTypography.caption,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.caption.copyWith(fontSize: 11),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
