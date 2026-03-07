import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/status_badge.dart';
import '../providers/location_provider.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  final MapController _mapController = MapController();

  // Mock incident markers
  final List<_IncidentMarker> _incidents = [
    _IncidentMarker(
      position: const LatLng(19.0820, 72.8810),
      title: 'Pickpocketing Alert',
      type: BadgeType.alert,
    ),
    _IncidentMarker(
      position: const LatLng(19.0700, 72.8700),
      title: 'Traffic Incident',
      type: BadgeType.warning,
    ),
    _IncidentMarker(
      position: const LatLng(19.0800, 72.8900),
      title: 'Tourist Assistance Point',
      type: BadgeType.active,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: location.currentPosition,
              initialZoom: 14.0,
            ),
            children: [
              // Dark tiles
              TileLayer(
                urlTemplate:
                    'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.touristsafety.app',
              ),
              // User location marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: location.currentPosition,
                    width: 30,
                    height: 30,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accentBlue.withValues(alpha: 0.3),
                        border:
                            Border.all(color: AppColors.accentBlue, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentBlue,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Incident markers
                  ..._incidents.map((incident) => Marker(
                        point: incident.position,
                        width: 36,
                        height: 36,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.alertRed.withValues(alpha: 0.2),
                          ),
                          child: const Icon(
                            Icons.warning_rounded,
                            color: AppColors.alertRed,
                            size: 22,
                          ),
                        ),
                      )),
                ],
              ),
              // High-risk zone circles
              CircleLayer(
                circles: [
                  CircleMarker(
                    point: const LatLng(19.066418, 72.878737),
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                    borderColor: AppColors.alertRed.withValues(alpha: 0.4),
                    borderStrokeWidth: 2,
                  ),
                  CircleMarker(
                    point: const LatLng(19.101552, 72.895888),
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                    borderColor: AppColors.alertRed.withValues(alpha: 0.4),
                    borderStrokeWidth: 2,
                  ),
                  CircleMarker(
                    point: const LatLng(19.043794, 72.853642),
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                    borderColor: AppColors.alertRed.withValues(alpha: 0.4),
                    borderStrokeWidth: 2,
                  ),
                  CircleMarker(
                    point: const LatLng(18.965636, 72.825986),
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                    borderColor: AppColors.alertRed.withValues(alpha: 0.4),
                    borderStrokeWidth: 2,
                  ),
                  CircleMarker(
                    point: const LatLng(19.156275, 72.928302),
                    radius: 500,
                    useRadiusInMeter: true,
                    color: AppColors.alertRed.withValues(alpha: 0.15),
                    borderColor: AppColors.alertRed.withValues(alpha: 0.4),
                    borderStrokeWidth: 2,
                  ),
                ],
              ),
            ],
          ),

          // Top search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: Row(
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.textPrimary, size: 20),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search,
                            color: AppColors.textSecondary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            style: AppTypography.body.copyWith(fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search location...',
                              hintStyle: AppTypography.caption,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              filled: false,
                              contentPadding: EdgeInsets.zero,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom legend sheet
          DraggableScrollableSheet(
            initialChildSize: 0.12,
            minChildSize: 0.08,
            maxChildSize: 0.35,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: ListView(
                  controller: scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Map Legend', style: AppTypography.h2),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.accentBlue,
                      label: 'Your Location',
                      badge: const StatusBadge(
                          label: 'Active', type: BadgeType.active),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.alertRed,
                      label: 'Incident Reports',
                      badge: const StatusBadge(
                          label: 'Alert', type: BadgeType.alert),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.warning,
                      label: 'Caution Zones',
                      badge: const StatusBadge(
                          label: 'Warning', type: BadgeType.warning),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.alertRed.withValues(alpha: 0.4),
                      label: 'High Risk Zones',
                      badge: const StatusBadge(
                          label: 'Danger', type: BadgeType.alert),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.success,
                      label: 'Safe Zones',
                      badge: const StatusBadge(
                          label: 'Safe', type: BadgeType.active),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      // FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _mapController.move(location.currentPosition, 15.0);
        },
        backgroundColor: AppColors.accentBlue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

class _IncidentMarker {
  final LatLng position;
  final String title;
  final BadgeType type;

  _IncidentMarker({
    required this.position,
    required this.title,
    required this.type,
  });
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final Widget badge;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTypography.body)),
        badge,
      ],
    );
  }
}
