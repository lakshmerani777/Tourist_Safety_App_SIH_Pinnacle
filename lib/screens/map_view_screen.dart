import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/status_badge.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  final MapController _mapController = MapController();

  static const List<LatLng> _highRiskZoneCenters = [
    LatLng(19.066418, 72.878737),
    LatLng(19.101552, 72.895888),
    LatLng(19.043794, 72.853642),
    LatLng(18.965636, 72.825986),
    LatLng(19.156275, 72.928302),
  ];

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

  Future<void> _launchMapsSearch(String query) async {
    final Uri url = Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open map search')),
        );
      }
    }
  }

  List<Marker> _buildMarkers(LatLng userPosition) {
    return [
      Marker(
        point: userPosition,
        width: 40,
        height: 40,
        child: const Icon(Icons.location_on, color: AppColors.accentBlue, size: 40),
      ),
      ..._incidents.asMap().entries.map((e) => Marker(
            point: e.value.position,
            width: 40,
            height: 40,
            child: Icon(
              Icons.warning,
              color: e.value.type == BadgeType.alert
                  ? AppColors.alertRed
                  : e.value.type == BadgeType.warning
                      ? AppColors.warning
                      : AppColors.success,
              size: 30,
            ),
          )),
    ];
  }

  List<CircleMarker> _buildCircles() {
    const fillColor = AppColors.alertRed;
    const strokeColor = AppColors.alertRed;
    return [
      for (var i = 0; i < _highRiskZoneCenters.length; i++)
        CircleMarker(
          point: _highRiskZoneCenters[i],
          radius: 500,
          useRadiusInMeter: true,
          color: fillColor.withValues(alpha: 0.15),
          borderColor: strokeColor.withValues(alpha: 0.4),
          borderStrokeWidth: 2,
        ),
    ];
  }

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
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.tourist_safety_app_sih_pinnacle',
              ),
              CircleLayer(
                circles: _buildCircles(),
              ),
              MarkerLayer(
                markers: _buildMarkers(location.currentPosition),
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

          // Current Location & Weather Row
          Positioned(
            top: MediaQuery.of(context).padding.top + 68,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              child: Row(
                children: [
                  // Location Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.accentBlue.withValues(alpha: 0.15),
                          ),
                          child: const Icon(Icons.my_location,
                              color: AppColors.accentBlue, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Current Location',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.accentBlue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                )),
                            Text(location.currentAddress,
                                style: AppTypography.body
                                    .copyWith(fontSize: 13, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Weather Card
                  Consumer(
                    builder: (context, ref, _) {
                      final weather = ref.watch(weatherProvider);
                      final data = weather.weather;
                      if (weather.isLoading || data == null) {
                        return const SizedBox.shrink();
                      }
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(data.icon, color: AppColors.warning, size: 28),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      '${data.temperature.round()}°C',
                                      style: AppTypography.h2.copyWith(fontSize: 16),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: data.aqiColor.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        data.aqiLabel,
                                        style: AppTypography.caption.copyWith(
                                          fontSize: 10,
                                          color: data.aqiColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${data.description} · AQI ${data.aqi}',
                                  style: AppTypography.caption.copyWith(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          // Left Quick Actions (Nearby Services)
          Positioned(
            top: MediaQuery.of(context).padding.top + 140,
            left: 16,
            bottom: 120, // Leave room for legend sheet
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _QuickActionButton(
                    icon: Icons.local_hospital,
                    color: Colors.redAccent,
                    tooltip: 'Nearby Hospitals',
                    onPressed: () => _launchMapsSearch('hospitals near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.local_police,
                    color: Colors.blueAccent,
                    tooltip: 'Police Stations',
                    onPressed: () => _launchMapsSearch('police stations near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.local_pharmacy,
                    color: Colors.green,
                    tooltip: 'Pharmacies',
                    onPressed: () => _launchMapsSearch('pharmacies near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.account_balance,
                    color: Colors.orange,
                    tooltip: 'Embassies',
                    onPressed: () => _launchMapsSearch('embassy near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.atm,
                    color: Colors.teal,
                    tooltip: 'ATMs',
                    onPressed: () => _launchMapsSearch('ATMs near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.directions_transit,
                    color: Colors.purple,
                    tooltip: 'Public Transit',
                    onPressed: () => _launchMapsSearch('public transit near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.wc,
                    color: Colors.brown,
                    tooltip: 'Public Restrooms',
                    onPressed: () => _launchMapsSearch('public restrooms near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.camera_alt,
                    color: Colors.indigo,
                    tooltip: 'Tourist Attractions',
                    onPressed: () => _launchMapsSearch('tourist attractions near me'),
                  ),
                ],
              ),
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
                    const SizedBox(height: 12),
                    Text(
                      'Map data © OpenStreetMap contributors',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
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

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onPressed;

  const _QuickActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: Tooltip(
            message: tooltip,
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, color: color, size: 24),
            ),
          ),
        ),
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
