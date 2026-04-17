import 'package:flutter/material.dart';
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
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PoliceDashboardHome()),
      );
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
  int _selectedTab = 0;
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
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const PoliceDashboardLoginScreen()),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const VerticalDivider(width: 1, color: AppColors.border),
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
          title: Text('New Unsafe Zone', style: AppTypography.h2),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    hintText: 'Zone Name',
                    hintStyle: AppTypography.caption,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  style: AppTypography.body,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Description',
                    hintStyle: AppTypography.caption,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: severity,
                  dropdownColor: AppColors.card,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    labelText: 'Severity',
                    labelStyle: AppTypography.caption,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: AppColors.border)),
                  ),
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
              const Spacer(),
              if (_isDrawingZone) ...[
                Text('Tap map to draw zone (${_drawingPoints.length} points)',
                    style: AppTypography.caption.copyWith(color: AppColors.warning)),
                const SizedBox(width: 16),
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
                  label: const Text('Draw Unsafe Zone'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
                ),
            ],
          ),
        ),
        const Divider(height: 1, color: AppColors.border),
        // ─── Map ───
        Expanded(
          child: StreamBuilder<List<UnsafeZone>>(
            stream: widget.firestore.streamUnsafeZones(),
            builder: (context, zoneSnap) {
              final zones = zoneSnap.data ?? [];
              return StreamBuilder<List<TouristLocation>>(
                stream: widget.firestore.streamTouristLocations(),
                builder: (context, touristSnap) {
                  final tourists = touristSnap.data ?? [];
                  return StreamBuilder<List<IncidentReport>>(
                    stream: widget.firestore.streamIncidents(),
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
                                  isDotted: true,
                                ),
                            ],
                          ),
                          // Drawing point markers
                          if (_isDrawingZone)
                            MarkerLayer(
                              markers: _drawingPoints.map((p) => Marker(
                                point: p,
                                width: 16,
                                height: 16,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: AppColors.warning,
                                    border: Border.all(color: Colors.white, width: 2),
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
  void _showComposeDialog() {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final helplineCtrl = TextEditingController(text: '1363');
    String severity = 'MEDIUM';
    String? targetGender;
    final nationalityCtrl = TextEditingController();
    final List<LatLng> geofencePoints = [];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Compose Alert', style: AppTypography.h2),
          content: SizedBox(
            width: 600,
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
                    maxLines: 3,
                    decoration: _inputDeco('Description'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: locationCtrl,
                    style: AppTypography.body,
                    decoration: _inputDeco('Location (e.g. Colaba, Mumbai)'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: severity,
                          dropdownColor: AppColors.card,
                          style: AppTypography.body,
                          decoration: _inputDeco('Severity'),
                          items: ['LOW', 'MEDIUM', 'HIGH'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (val) { if (val != null) setDialogState(() => severity = val); },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: targetGender,
                          dropdownColor: AppColors.card,
                          style: AppTypography.body,
                          decoration: _inputDeco('Target Gender'),
                          items: [
                            const DropdownMenuItem(value: null, child: Text('All')),
                            const DropdownMenuItem(value: 'female', child: Text('Women Only')),
                            const DropdownMenuItem(value: 'male', child: Text('Men Only')),
                          ],
                          onChanged: (val) => setDialogState(() => targetGender = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nationalityCtrl,
                    style: AppTypography.body,
                    decoration: _inputDeco('Target Nationalities (comma-separated, empty = all)'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: helplineCtrl,
                    style: AppTypography.body,
                    decoration: _inputDeco('Helpline Number'),
                  ),
                  const SizedBox(height: 16),
                  // Geofence drawing
                  Text('Geofence Targeting', style: AppTypography.body.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 250,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(19.062641, 72.830899),
                          initialZoom: 12,
                          onTap: (tapPos, point) {
                            setDialogState(() => geofencePoints.add(point));
                          },
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png'),
                          if (geofencePoints.length >= 3)
                            PolygonLayer(polygons: [
                              Polygon(
                                points: geofencePoints,
                                color: AppColors.warning.withValues(alpha: 0.2),
                                borderColor: AppColors.warning,
                                borderStrokeWidth: 2,
                                isDotted: true,
                              ),
                            ]),
                          MarkerLayer(
                            markers: geofencePoints.map((p) => Marker(
                              point: p,
                              width: 12,
                              height: 12,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.warning,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('${geofencePoints.length} points drawn',
                          style: AppTypography.caption.copyWith(color: AppColors.warning)),
                      const Spacer(),
                      if (geofencePoints.isNotEmpty)
                        TextButton(
                          onPressed: () => setDialogState(() => geofencePoints.clear()),
                          child: Text('Clear', style: AppTypography.caption.copyWith(color: AppColors.alertRed)),
                        ),
                    ],
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
                final nationalities = nationalityCtrl.text.trim().isEmpty
                    ? null
                    : nationalityCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

                final alert = SafetyAlert(
                  id: '',
                  title: titleCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                  severity: severity,
                  location: locationCtrl.text.trim(),
                  geofence: geofencePoints.length >= 3 ? List.from(geofencePoints) : null,
                  targetNationalities: nationalities,
                  targetGender: targetGender,
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
            stream: widget.firestore.streamAlerts(),
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
                                  if (a.targetGender != null)
                                    StatusBadge(label: a.targetGender == 'female' ? 'Women' : 'Men', type: BadgeType.active),
                                  if (a.geofence != null) ...[
                                    const SizedBox(width: 8),
                                    StatusBadge(label: 'Geofenced', type: BadgeType.warning),
                                  ],
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

class _IncidentManagerView extends StatelessWidget {
  final FirestoreService firestore;
  const _IncidentManagerView({required this.firestore});

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
            stream: firestore.streamIncidents(),
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
                                onTap: () => firestore.updateIncidentStatus(inc.id, 'reviewed'),
                              ),
                            if (inc.status == 'reviewed') ...[
                              _StatusButton(
                                label: 'Mark Resolved',
                                color: AppColors.success,
                                onTap: () => firestore.updateIncidentStatus(inc.id, 'resolved'),
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
