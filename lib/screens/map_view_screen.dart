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
import '../l10n/app_localizations.dart';
import '../services/firestore_service.dart';
import '../models/firestore_models.dart';

class MapViewScreen extends ConsumerStatefulWidget {
  const MapViewScreen({super.key});

  @override
  ConsumerState<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends ConsumerState<MapViewScreen> {
  final MapController _mapController = MapController();
  final FirestoreService _firestore = FirestoreService();

  Future<void> _launchMapsSearch(String query) async {
    final Uri url = Uri.parse('geo:0,0?q=${Uri.encodeComponent(query)}');
    if (!await launchUrl(url)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)?.errorMapSearch ?? 'Could not open map search')),
        );
      }
    }
  }

  Color _severityColor(String severity) {
    switch (severity) {
      case 'HIGH':
        return AppColors.alertRed;
      case 'MEDIUM':
        return AppColors.warning;
      default:
        return AppColors.accentBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(locationProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Map with Firestore streams
          StreamBuilder<List<UnsafeZone>>(
            stream: _firestore.streamUnsafeZones(),
            builder: (context, zoneSnap) {
              final zones = zoneSnap.data ?? [];
              return StreamBuilder<List<IncidentReport>>(
                stream: _firestore.streamIncidents(),
                builder: (context, incSnap) {
                  final incidents = incSnap.data ?? [];
                  return FlutterMap(
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
                      // Unsafe zone polygons from Firestore
                      if (zones.isNotEmpty)
                        PolygonLayer(
                          polygons: zones.map((z) => Polygon(
                            points: z.polygon,
                            color: AppColors.alertRed.withValues(alpha: 0.25),
                            borderColor: AppColors.alertRed.withValues(alpha: 0.7),
                            borderStrokeWidth: 3,
                            label: '⚠ ${z.name}',
                            labelStyle: AppTypography.caption.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              shadows: [
                                const Shadow(
                                  blurRadius: 4,
                                  color: Colors.black54,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          )).toList(),
                        ),
                      // User location marker
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: location.currentPosition,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: AppColors.accentBlue, size: 40),
                          ),
                          // Incident markers from Firestore
                          ...incidents.map((inc) => Marker(
                            point: LatLng(inc.latitude, inc.longitude),
                            width: 40,
                            height: 40,
                            child: Tooltip(
                              message: '${inc.type}: ${inc.address}',
                              child: Icon(Icons.warning, color: _severityColor('HIGH'), size: 30),
                            ),
                          )),
                        ],
                      ),
                    ],
                  );
                },
              );
            },
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
                              hintText: AppLocalizations.of(context)?.searchLocation ?? 'Search location...',
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
                            Text(AppLocalizations.of(context)?.currentLocation ?? 'Current Location',
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
                    tooltip: AppLocalizations.of(context)?.nearbyHospitals ?? 'Nearby Hospitals',
                    onPressed: () => _launchMapsSearch('hospitals near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.local_police,
                    color: Colors.blueAccent,
                    tooltip: AppLocalizations.of(context)?.policeStations ?? 'Police Stations',
                    onPressed: () => _launchMapsSearch('police stations near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.local_pharmacy,
                    color: Colors.green,
                    tooltip: AppLocalizations.of(context)?.pharmacies ?? 'Pharmacies',
                    onPressed: () => _launchMapsSearch('pharmacies near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.account_balance,
                    color: Colors.orange,
                    tooltip: AppLocalizations.of(context)?.embassies ?? 'Embassies',
                    onPressed: () => _launchMapsSearch('embassy near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.atm,
                    color: Colors.teal,
                    tooltip: AppLocalizations.of(context)?.atms ?? 'ATMs',
                    onPressed: () => _launchMapsSearch('ATMs near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.directions_transit,
                    color: Colors.purple,
                    tooltip: AppLocalizations.of(context)?.publicTransit ?? 'Public Transit',
                    onPressed: () => _launchMapsSearch('public transit near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.wc,
                    color: Colors.brown,
                    tooltip: AppLocalizations.of(context)?.publicRestrooms ?? 'Public Restrooms',
                    onPressed: () => _launchMapsSearch('public restrooms near me'),
                  ),
                  const SizedBox(height: 12),
                  _QuickActionButton(
                    icon: Icons.camera_alt,
                    color: Colors.indigo,
                    tooltip: AppLocalizations.of(context)?.touristAttractions ?? 'Tourist Attractions',
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
                    Text(AppLocalizations.of(context)?.mapLegend ?? 'Map Legend', style: AppTypography.h2),
                    const SizedBox(height: 12),
                    _LegendItem(
                      color: AppColors.accentBlue,
                      label: AppLocalizations.of(context)?.legendYourLocation ?? 'Your Location',
                      badge: StatusBadge(
                          label: AppLocalizations.of(context)?.activeBadge ?? 'Active', type: BadgeType.active),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.alertRed,
                      label: AppLocalizations.of(context)?.legendIncidentReports ?? 'Incident Reports',
                      badge: StatusBadge(
                          label: AppLocalizations.of(context)?.alertBadge ?? 'Alert', type: BadgeType.alert),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.warning,
                      label: AppLocalizations.of(context)?.legendCautionZones ?? 'Caution Zones',
                      badge: StatusBadge(
                          label: AppLocalizations.of(context)?.warningBadge ?? 'Warning', type: BadgeType.warning),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.alertRed.withValues(alpha: 0.4),
                      label: AppLocalizations.of(context)?.legendHighRiskZones ?? 'High Risk Zones',
                      badge: StatusBadge(
                          label: AppLocalizations.of(context)?.dangerBadge ?? 'Danger', type: BadgeType.alert),
                    ),
                    const SizedBox(height: 8),
                    _LegendItem(
                      color: AppColors.success,
                      label: AppLocalizations.of(context)?.legendSafeZones ?? 'Safe Zones',
                      badge: StatusBadge(
                          label: AppLocalizations.of(context)?.safeBadge ?? 'Safe', type: BadgeType.active),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.mapCopyright ?? 'Map data © OpenStreetMap contributors',
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
