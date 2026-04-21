import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/firestore_models.dart';
import '../services/firestore_service.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/widgets/safety_card.dart';
import '../core/widgets/status_badge.dart';

/// The secret access code for the police dashboard.
const String _policeAccessCode = 'POLICE2026';

// ════════════════════════════════════════════════════
// ENTRY: Police Dashboard Login
// ════════════════════════════════════════════════════

class PoliceDashboardLoginScreen extends StatefulWidget {
  const PoliceDashboardLoginScreen({super.key});

  @override
  State<PoliceDashboardLoginScreen> createState() => _PoliceDashboardLoginScreenState();
}

class _PoliceDashboardLoginScreenState extends State<PoliceDashboardLoginScreen> {
  final _codeController = TextEditingController();
  String? _error;

  void _login() {
    if (_codeController.text.trim() == _policeAccessCode) {
      context.go('/police-dashboard/home');
    } else {
      setState(() => _error = 'Invalid access code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 420),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.accentBlue.withValues(alpha: 0.15),
                ),
                child: const Icon(Icons.shield, color: AppColors.accentBlue, size: 40),
              ),
              const SizedBox(height: 24),
              Text('Security Dashboard', style: AppTypography.h1),
              const SizedBox(height: 8),
              Text(
                'Enter your access code to proceed',
                style: AppTypography.caption,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _codeController,
                obscureText: true,
                style: AppTypography.body,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Access Code',
                  hintStyle: AppTypography.caption,
                  filled: true,
                  fillColor: AppColors.card,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: AppColors.accentBlue),
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: AppTypography.caption.copyWith(color: AppColors.alertRed)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Enter Dashboard', style: AppTypography.body.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// DASHBOARD HOME WITH TABS
// ════════════════════════════════════════════════════

class PoliceDashboardHome extends StatefulWidget {
  const PoliceDashboardHome({super.key});

  @override
  State<PoliceDashboardHome> createState() => _PoliceDashboardHomeState();
}

class _PoliceDashboardHomeState extends State<PoliceDashboardHome> {
  int _selectedTab = 1;
  final FirestoreService _firestore = FirestoreService();

  static const _tabs = [
    _TabItem(icon: Icons.map, label: 'Map'),
    _TabItem(icon: Icons.warning_amber, label: 'Alerts'),
    _TabItem(icon: Icons.report, label: 'Incidents'),
    _TabItem(icon: Icons.smart_toy, label: 'AI Config'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ─── Side Navigation ───
          Container(
            width: 220,
            color: AppColors.card,
            child: Column(
              children: [
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shield, color: AppColors.accentBlue, size: 28),
                    const SizedBox(width: 10),
                    Text('Police HQ', style: AppTypography.h2),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Security Dashboard', style: AppTypography.caption),
                const SizedBox(height: 32),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                ...List.generate(_tabs.length, (i) => _NavItem(
                  icon: _tabs[i].icon,
                  label: _tabs[i].label,
                  isSelected: _selectedTab == i,
                  onTap: () => setState(() => _selectedTab = i),
                )),
                const Spacer(),
                const Divider(color: AppColors.border),
                ListTile(
                  leading: const Icon(Icons.logout, color: AppColors.alertRed, size: 20),
                  title: Text('Logout', style: AppTypography.body.copyWith(color: AppColors.alertRed)),
                  onTap: () => context.go('/police-dashboard'),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          Container(width: 1, color: AppColors.border),
          // ─── Main Content ───
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedTab) {
      case 0:
        return _DashboardMapView(firestore: _firestore);
      case 1:
        return _AlertCenterView(firestore: _firestore);
      case 2:
        return _IncidentManagerView(firestore: _firestore);
      case 3:
        return _AiConfigView(firestore: _firestore);
      default:
        return const Center(child: Text('Select a tab'));
    }
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  const _TabItem({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.accentBlue.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: isSelected ? AppColors.accentBlue : AppColors.textSecondary, size: 20),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: isSelected ? AppColors.accentBlue : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// TAB 1: MAP VIEW
// ════════════════════════════════════════════════════

class _DashboardMapView extends StatefulWidget {
  final FirestoreService firestore;
  const _DashboardMapView({required this.firestore});

  @override
  State<_DashboardMapView> createState() => _DashboardMapViewState();
}

class _DashboardMapViewState extends State<_DashboardMapView> {
  final MapController _mapController = MapController();
  bool _isDrawingZone = false;
  final List<LatLng> _drawingPoints = [];
  bool _showZonePanel = true;

  // Cache streams in state to prevent infinite rebuild loops
  late final Stream<List<UnsafeZone>> _zonesStream;
  late final Stream<List<TouristLocation>> _touristsStream;
  late final Stream<List<IncidentReport>> _incidentsStream;

  @override
  void initState() {
    super.initState();
    _zonesStream = widget.firestore.streamUnsafeZones();
    _touristsStream = widget.firestore.streamTouristLocations();
    _incidentsStream = widget.firestore.streamIncidents();
    // Defer map rendering to avoid FlutterMap's internal CanvasKit crash
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) setState(() => _mapReady = true);
        });
      }
    });
  }

  bool _mapReady = false;

  void _onMapTap(TapPosition tapPos, LatLng point) {
    if (!_isDrawingZone) return;
    setState(() => _drawingPoints.add(point));
  }

  Future<void> _saveZone() async {
    if (_drawingPoints.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Draw at least 3 points to create a zone')),
      );
      return;
    }

    final nameController = TextEditingController();
    final descController = TextEditingController();
    String severity = 'HIGH';

    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('New High Risk Zone', style: AppTypography.h2),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.body,
                  decoration: _inputDeco('Zone Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: AppTypography.body,
                  maxLines: 3,
                  decoration: _inputDeco('Description'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: severity,
                  dropdownColor: AppColors.card,
                  style: AppTypography.body,
                  decoration: _inputDeco('Severity'),
                  items: ['LOW', 'MEDIUM', 'HIGH'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                  onChanged: (val) => setDialogState(() => severity = val!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.textSecondary))),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
              child: Text('Save Zone', style: AppTypography.body.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );

    if (result == true) {
      final zone = UnsafeZone(
        id: '',
        name: nameController.text.trim().isEmpty ? 'Unsafe Zone' : nameController.text.trim(),
        description: descController.text.trim(),
        severity: severity,
        polygon: List.from(_drawingPoints),
        createdAt: DateTime.now(),
      );
      await widget.firestore.addUnsafeZone(zone);
    }

    setState(() {
      _isDrawingZone = false;
      _drawingPoints.clear();
    });
  }

  Future<void> _confirmDeleteZone(UnsafeZone zone) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete Zone', style: AppTypography.h2),
        content: Text('Are you sure you want to delete "${zone.name}"?', style: AppTypography.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.textSecondary))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
            child: Text('Delete', style: AppTypography.body.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await widget.firestore.deleteUnsafeZone(zone.id);
    }
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.caption,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ─── Toolbar ───
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.card,
          child: Row(
            children: [
              Text('Live Map', style: AppTypography.h2),
              const SizedBox(width: 16),
              IconButton(
                icon: Icon(_showZonePanel ? Icons.view_sidebar : Icons.view_sidebar_outlined,
                    color: _showZonePanel ? AppColors.accentBlue : AppColors.textSecondary, size: 20),
                tooltip: 'Toggle zone panel',
                onPressed: () => setState(() => _showZonePanel = !_showZonePanel),
              ),
              const Spacer(),
              if (_isDrawingZone) ...[
                Text('Tap map to draw zone (${_drawingPoints.length} pts)',
                    style: AppTypography.caption.copyWith(color: AppColors.warning)),
                const SizedBox(width: 16),
                if (_drawingPoints.isNotEmpty)
                  OutlinedButton(
                    onPressed: () => setState(() {
                      if (_drawingPoints.isNotEmpty) _drawingPoints.removeLast();
                    }),
                    child: Text('Undo', style: AppTypography.body.copyWith(color: AppColors.warning)),
                  ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: _saveZone,
                  icon: const Icon(Icons.save, size: 18),
                  label: const Text('Save Zone'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () => setState(() {
                    _isDrawingZone = false;
                    _drawingPoints.clear();
                  }),
                  child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.alertRed)),
                ),
              ] else
                ElevatedButton.icon(
                  onPressed: () => setState(() => _isDrawingZone = true),
                  icon: const Icon(Icons.draw, size: 18),
                  label: const Text('Draw High Risk Zone'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // ─── Map + Zone Panel ───
        Expanded(
          child: Row(
            children: [
              // Map area
              Expanded(
                flex: 3,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 10 || constraints.maxHeight < 10) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight,
                      child: !_mapReady
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 16),
                                  Text('Loading map...', style: AppTypography.caption),
                                ],
                              ),
                            )
                          : StreamBuilder<List<UnsafeZone>>(
                        stream: _zonesStream,
                        builder: (context, zoneSnap) {
                          final zones = zoneSnap.data ?? [];
                          return StreamBuilder<List<TouristLocation>>(
                            stream: _touristsStream,
                            builder: (context, touristSnap) {
                              final tourists = touristSnap.data ?? [];
                              return StreamBuilder<List<IncidentReport>>(
                                stream: _incidentsStream,
                                builder: (context, incidentSnap) {
                                  final incidents = incidentSnap.data ?? [];
                                  return FlutterMap(
                                    mapController: _mapController,
                                    options: MapOptions(
                                      initialCenter: const LatLng(19.062641, 72.830899),
                                      initialZoom: 13,
                                      onTap: _onMapTap,
                                    ),
                                    children: [
                                      TileLayer(
                                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                        userAgentPackageName: 'com.example.tourist_safety_app',
                                      ),
                                      // Unsafe zone polygons
                                      PolygonLayer(
                                        polygons: [
                                          ...zones.map((z) => Polygon(
                                            points: z.polygon,
                                            color: _severityColor(z.severity).withValues(alpha: 0.2),
                                            borderColor: _severityColor(z.severity),
                                            borderStrokeWidth: 2,
                                            label: z.name,
                                            labelStyle: AppTypography.caption.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          )),
                                          // Drawing preview
                                          if (_isDrawingZone && _drawingPoints.length >= 3)
                                            Polygon(
                                              points: _drawingPoints,
                                              color: AppColors.warning.withValues(alpha: 0.2),
                                              borderColor: AppColors.warning,
                                              borderStrokeWidth: 2,
                                              pattern: const StrokePattern.dotted(),
                                            ),
                                        ],
                                      ),
                                      // Drawing point markers
                                      if (_isDrawingZone)
                                        MarkerLayer(
                                          markers: _drawingPoints.asMap().entries.map((e) => Marker(
                                            point: e.value,
                                            width: 20,
                                            height: 20,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.warning,
                                                border: Border.all(color: Colors.white, width: 2),
                                              ),
                                              child: Center(
                                                child: Text('${e.key + 1}',
                                                    style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                              ),
                                            ),
                                          )).toList(),
                                        ),
                                      // Tourist location markers
                                      MarkerLayer(
                                        markers: tourists.map((t) => Marker(
                                          point: LatLng(t.latitude, t.longitude),
                                          width: 36,
                                          height: 36,
                                          child: Tooltip(
                                            message: '${t.name} (${t.nationality ?? "Unknown"})',
                                            child: Container(
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: AppColors.accentBlue.withValues(alpha: 0.3),
                                                border: Border.all(color: AppColors.accentBlue, width: 2),
                                              ),
                                              child: const Icon(Icons.person, color: AppColors.accentBlue, size: 18),
                                            ),
                                          ),
                                        )).toList(),
                                      ),
                                      // Incident markers
                                      MarkerLayer(
                                        markers: incidents.map((inc) => Marker(
                                          point: LatLng(inc.latitude, inc.longitude),
                                          width: 30,
                                          height: 30,
                                          child: Tooltip(
                                            message: '${inc.type}: ${inc.description}',
                                            child: const Icon(Icons.warning, color: AppColors.alertRed, size: 24),
                                          ),
                                        )).toList(),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              // Zone management panel
              if (_showZonePanel) ...[
                Container(width: 1, color: AppColors.border),
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: AppColors.card,
                        child: Row(
                          children: [
                            const Icon(Icons.layers, color: AppColors.alertRed, size: 20),
                            const SizedBox(width: 8),
                            Text('High Risk Zones', style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      Expanded(
                        child: StreamBuilder<List<UnsafeZone>>(
                          stream: _zonesStream,
                          builder: (context, snap) {
                            if (snap.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }
                            final zones = snap.data ?? [];
                            if (zones.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map_outlined, color: AppColors.textSecondary, size: 40),
                                      const SizedBox(height: 12),
                                      Text('No zones defined', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                                      const SizedBox(height: 4),
                                      Text('Use "Draw High Risk Zone" to add', style: AppTypography.caption, textAlign: TextAlign.center),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return ListView.separated(
                              padding: const EdgeInsets.all(12),
                              itemCount: zones.length,
                              separatorBuilder: (_, __) => const SizedBox(height: 8),
                              itemBuilder: (context, i) {
                                final z = zones[i];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppColors.card,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border(
                                      left: BorderSide(color: _severityColor(z.severity), width: 4),
                                      top: BorderSide(color: AppColors.border),
                                      right: BorderSide(color: AppColors.border),
                                      bottom: BorderSide(color: AppColors.border),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(z.name, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 14)),
                                          ),
                                          StatusBadge(
                                            label: z.severity,
                                            type: z.severity == 'HIGH'
                                                ? BadgeType.alert
                                                : z.severity == 'MEDIUM'
                                                    ? BadgeType.warning
                                                    : BadgeType.active,
                                          ),
                                        ],
                                      ),
                                      if (z.description.isNotEmpty) ...[
                                        const SizedBox(height: 4),
                                        Text(z.description, style: AppTypography.caption, maxLines: 2, overflow: TextOverflow.ellipsis),
                                      ],
                                      const SizedBox(height: 4),
                                      Text('${z.polygon.length} vertices', style: AppTypography.caption.copyWith(fontSize: 11)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          _ZoneActionButton(
                                            icon: Icons.center_focus_strong,
                                            label: 'Focus',
                                            color: AppColors.accentBlue,
                                            onTap: () {
                                              if (z.polygon.isNotEmpty) {
                                                // Calculate center of polygon
                                                double lat = 0, lng = 0;
                                                for (final p in z.polygon) {
                                                  lat += p.latitude;
                                                  lng += p.longitude;
                                                }
                                                _mapController.move(
                                                  LatLng(lat / z.polygon.length, lng / z.polygon.length),
                                                  15,
                                                );
                                              }
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          _ZoneActionButton(
                                            icon: z.isActive ? Icons.visibility : Icons.visibility_off,
                                            label: z.isActive ? 'Active' : 'Hidden',
                                            color: z.isActive ? AppColors.success : AppColors.textSecondary,
                                            onTap: () => widget.firestore.toggleUnsafeZone(z.id, !z.isActive),
                                          ),
                                          const SizedBox(width: 8),
                                          _ZoneActionButton(
                                            icon: Icons.delete_outline,
                                            label: 'Delete',
                                            color: AppColors.alertRed,
                                            onTap: () => _confirmDeleteZone(z),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
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
}

class _ZoneActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ZoneActionButton({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: color.withValues(alpha: 0.1),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(height: 2),
              Text(label, style: AppTypography.caption.copyWith(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// TAB 2: ALERT CENTER
// ════════════════════════════════════════════════════

class _AlertCenterView extends StatefulWidget {
  final FirestoreService firestore;
  const _AlertCenterView({required this.firestore});

  @override
  State<_AlertCenterView> createState() => _AlertCenterViewState();
}

class _AlertCenterViewState extends State<_AlertCenterView> {
  late final Stream<List<SafetyAlert>> _alertsStream;

  @override
  void initState() {
    super.initState();
    _alertsStream = widget.firestore.streamAlerts();
  }
  void _showComposeDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final helplineCtrl = TextEditingController(text: '1363');
    String severity = 'MEDIUM';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Compose Alert', style: AppTypography.h2),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleCtrl,
                    style: AppTypography.body,
                    decoration: _inputDeco('Alert Title'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descCtrl,
                    style: AppTypography.body,
                    maxLines: 4,
                    decoration: _inputDeco('Alert Body / Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    style: AppTypography.body,
                    decoration: _inputDeco('Location (e.g. Colaba, Mumbai)'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: severity,
                    dropdownColor: AppColors.card,
                    style: AppTypography.body,
                    decoration: _inputDeco('Severity Level'),
                    items: [
                      DropdownMenuItem(value: 'LOW', child: Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.accentBlue)),
                        const SizedBox(width: 8),
                        const Text('LOW'),
                      ])),
                      DropdownMenuItem(value: 'MEDIUM', child: Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.warning)),
                        const SizedBox(width: 8),
                        const Text('MEDIUM'),
                      ])),
                      DropdownMenuItem(value: 'HIGH', child: Row(children: [
                        Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.alertRed)),
                        const SizedBox(width: 8),
                        const Text('HIGH'),
                      ])),
                    ],
                    onChanged: (val) { if (val != null) setDialogState(() => severity = val); },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: helplineCtrl,
                    style: AppTypography.body,
                    decoration: _inputDeco('Helpline Number'),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty) return;
                final alert = SafetyAlert(
                  id: '',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  severity: severity,
                  location: locationCtrl.text.trim(),
                  issuedAt: DateTime.now(),
                  helplineNumber: helplineCtrl.text.trim(),
                );
                await widget.firestore.broadcastAlert(alert);
                if (ctx.mounted) Navigator.pop(ctx);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
              child: Text('Broadcast Alert', style: AppTypography.body.copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) => InputDecoration(
        hintText: hint,
        hintStyle: AppTypography.caption,
        filled: true,
        fillColor: AppColors.background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
      );

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Toolbar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.card,
          child: Row(
            children: [
              Text('Alert Center', style: AppTypography.h2),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _showComposeDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('New Alert'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.alertRed),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // Alert List
        Expanded(
          child: StreamBuilder<List<SafetyAlert>>(
            stream: _alertsStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final alerts = snap.data ?? [];
              if (alerts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.notifications_off, color: AppColors.textSecondary, size: 48),
                      const SizedBox(height: 12),
                      Text('No active alerts', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: alerts.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final a = alerts[i];
                  return SafetyCard(
                    accentColor: _severityColor(a.severity),
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.warning_amber, color: _severityColor(a.severity), size: 28),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  StatusBadge(
                                    label: a.severity,
                                    type: a.severity == 'HIGH'
                                        ? BadgeType.alert
                                        : a.severity == 'MEDIUM'
                                            ? BadgeType.warning
                                            : BadgeType.active,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_formatTime(a.issuedAt), style: AppTypography.caption.copyWith(fontSize: 11)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(a.title, style: AppTypography.body.copyWith(fontWeight: FontWeight.w700, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(a.description, style: AppTypography.caption, maxLines: 3, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text('📍 ${a.location}', style: AppTypography.caption.copyWith(fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => widget.firestore.deactivateAlert(a.id),
                          icon: const Icon(Icons.close, color: AppColors.alertRed, size: 20),
                          tooltip: 'Deactivate',
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
}

// ════════════════════════════════════════════════════
// TAB 3: INCIDENT MANAGER
// ════════════════════════════════════════════════════

class _IncidentManagerView extends StatefulWidget {
  final FirestoreService firestore;
  const _IncidentManagerView({required this.firestore});

  @override
  State<_IncidentManagerView> createState() => _IncidentManagerViewState();
}

class _IncidentManagerViewState extends State<_IncidentManagerView> {
  late final Stream<List<IncidentReport>> _incidentsStream;

  @override
  void initState() {
    super.initState();
    _incidentsStream = widget.firestore.streamIncidents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.card,
          child: Row(
            children: [
              Text('Incident Reports', style: AppTypography.h2),
              const Spacer(),
              Text('Live Feed', style: AppTypography.caption.copyWith(color: AppColors.success)),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: StreamBuilder<List<IncidentReport>>(
            stream: _incidentsStream,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final incidents = snap.data ?? [];
              if (incidents.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.success, size: 48),
                      const SizedBox(height: 12),
                      Text('No incidents reported yet', style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                    ],
                  ),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: incidents.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final inc = incidents[i];
                  return SafetyCard(
                    accentColor: inc.status == 'resolved'
                        ? AppColors.success
                        : inc.status == 'reviewed'
                            ? AppColors.warning
                            : AppColors.alertRed,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            StatusBadge(
                              label: inc.status.toUpperCase(),
                              type: inc.status == 'resolved'
                                  ? BadgeType.active
                                  : inc.status == 'reviewed'
                                      ? BadgeType.warning
                                      : BadgeType.alert,
                            ),
                            const SizedBox(width: 8),
                            StatusBadge(label: inc.type, type: BadgeType.warning),
                            const Spacer(),
                            Text(_formatTime(inc.reportedAt), style: AppTypography.caption.copyWith(fontSize: 11)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(inc.description.isEmpty ? 'No description provided' : inc.description,
                            style: AppTypography.body),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.textSecondary, size: 14),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(inc.address.isEmpty ? '${inc.latitude.toStringAsFixed(4)}, ${inc.longitude.toStringAsFixed(4)}' : inc.address,
                                  style: AppTypography.caption),
                            ),
                            if (inc.touristName != null) ...[
                              const SizedBox(width: 12),
                              const Icon(Icons.person, color: AppColors.textSecondary, size: 14),
                              const SizedBox(width: 4),
                              Text(inc.touristName!, style: AppTypography.caption),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          children: [
                            if (inc.status == 'pending')
                              _StatusButton(
                                label: 'Mark Reviewed',
                                color: AppColors.warning,
                                onTap: () => widget.firestore.updateIncidentStatus(inc.id, 'reviewed'),
                              ),
                            if (inc.status == 'reviewed') ...[
                              _StatusButton(
                                label: 'Mark Resolved',
                                color: AppColors.success,
                                onTap: () => widget.firestore.updateIncidentStatus(inc.id, 'resolved'),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: color.withValues(alpha: 0.12),
          border: Border.all(color: color.withValues(alpha: 0.5)),
        ),
        child: Text(label, style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

// ════════════════════════════════════════════════════
// TAB 4: AI CONFIGURATOR
// ════════════════════════════════════════════════════

class _AiConfigView extends StatefulWidget {
  final FirestoreService firestore;
  const _AiConfigView({required this.firestore});

  @override
  State<_AiConfigView> createState() => _AiConfigViewState();
}

class _AiConfigViewState extends State<_AiConfigView> {
  final _instructionsCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadInstructions();
  }

  Future<void> _loadInstructions() async {
    final instructions = await widget.firestore.getChatbotInstructions();
    _instructionsCtrl.text = instructions ?? '';
    setState(() => _isLoading = false);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    await widget.firestore.updateChatbotInstructions(_instructionsCtrl.text.trim());
    setState(() => _isSaving = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('AI instructions updated successfully', style: AppTypography.caption.copyWith(color: Colors.white)),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: AppColors.card,
          child: Row(
            children: [
              Text('AI Chatbot Configuration', style: AppTypography.h2),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.save, size: 18),
                label: Text(_isSaving ? 'Saving...' : 'Save Instructions'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SafetyCard(
                        accentColor: AppColors.accentBlue,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.accentBlue, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'These instructions are appended to the chatbot\'s base system prompt. They will take effect immediately for all tourist users.',
                                style: AppTypography.caption,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Custom Instructions', style: AppTypography.body.copyWith(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Expanded(
                        child: TextField(
                          controller: _instructionsCtrl,
                          style: AppTypography.body.copyWith(fontSize: 13, height: 1.6),
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: InputDecoration(
                            hintText: 'Enter custom instructions for the chatbot...\n\nExamples:\n- "Warn tourists about ongoing festival traffic near Dadar"\n- "Recommend avoiding Marine Drive after 11 PM tonight"\n- "There is a health advisory for water-borne diseases"',
                            hintStyle: AppTypography.caption.copyWith(fontSize: 12),
                            filled: true,
                            fillColor: AppColors.card,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}
