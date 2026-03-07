import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/status_badge.dart';
import '../providers/location_provider.dart';

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
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
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
        // Navigate to map
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
              Text('Tourist Safety', style: AppTypography.h2),
              Row(
                children: [
                  const StatusBadge(
                    label: 'Protected',
                    type: BadgeType.active,
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                    ),
                    child: const Icon(Icons.shield,
                        color: AppColors.accentBlue, size: 20),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Location Banner
          Builder(builder: (context) {
            final location = ref.watch(locationProvider);
            final lat = location.currentPosition.latitude.toStringAsFixed(6);
            final lng = location.currentPosition.longitude.toStringAsFixed(6);
            return SafetyCard(
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
                    child: const Icon(Icons.my_location,
                        color: AppColors.accentBlue, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: AppTypography.caption.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.accentBlue,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '16th Road, Bandra West',
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 16),

          // Safety Status Card
          SafetyCard(
            accentColor: AppColors.success,
            child: Row(
              children: [
                // Pulsing green dot
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.success.withValues(alpha: 0.2),
                        ),
                        child: Center(
                          child: Container(
                            width: 24,
                            height: 24,
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
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PROTECTED',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.success,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last updated: Just now',
                        style: AppTypography.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions
          Text('Quick Actions', style: AppTypography.h2),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _QuickActionCard(
                title: 'Report\nIncident',
                icon: Icons.report_problem_outlined,
                color: AppColors.warning,
                onTap: () {},
              ),
              _QuickActionCard(
                title: 'Share\nLocation',
                icon: Icons.share_location,
                color: AppColors.accentBlue,
                onTap: () {},
              ),
              _QuickActionCard(
                title: 'Emergency\nContacts',
                icon: Icons.phone_in_talk,
                color: AppColors.alertRed,
                onTap: () {},
              ),
              _QuickActionCard(
                title: 'Safety\nMap',
                icon: Icons.map_outlined,
                color: AppColors.accentBlue,
                onTap: () => context.push('/map'),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // SOS Button
          Center(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                context.push('/sos');
              },
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.alertRed.withValues(alpha: 0.15),
                    ),
                    child: Center(
                      child: Transform.scale(
                        scale: _pulseAnimation.value * 0.95,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.alertRed,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x40FF3B3B),
                                blurRadius: 20,
                                spreadRadius: 4,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              'SOS',
                              style: AppTypography.h1.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Recent Alerts
          Text('Recent Alerts', style: AppTypography.h2),
          const SizedBox(height: 16),
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
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        backgroundColor: AppColors.card,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications_outlined), label: 'Alerts'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: 'Profile'),
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
          border: Border.all(color: AppColors.border),
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
            Text(
              title,
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
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
                      child: Text(title,
                          style: AppTypography.body
                              .copyWith(fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),
          Text(time, style: AppTypography.caption.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
