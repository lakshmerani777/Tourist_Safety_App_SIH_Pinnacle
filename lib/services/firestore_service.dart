import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';

/// Central service for all Firestore reads/writes used by both
/// the tourist app and the police dashboard.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Collection References ───
  CollectionReference get _zones => _db.collection('unsafe_zones');
  CollectionReference get _incidents => _db.collection('incidents');
  CollectionReference get _alerts => _db.collection('alerts');
  CollectionReference get _touristLocations => _db.collection('tourist_locations');
  CollectionReference get _chatbotConfig => _db.collection('chatbot_config');

  // ════════════════════════════════════════════
  // UNSAFE ZONES
  // ════════════════════════════════════════════

  /// Stream all active unsafe zones in real time.
  Stream<List<UnsafeZone>> streamUnsafeZones() {
    return _zones
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(UnsafeZone.fromFirestore).toList());
  }

  /// Add a new unsafe zone (police dashboard).
  Future<void> addUnsafeZone(UnsafeZone zone) async {
    await _zones.add(zone.toFirestore());
  }

  /// Delete an unsafe zone.
  Future<void> deleteUnsafeZone(String id) async {
    await _zones.doc(id).delete();
  }

  /// Toggle active state.
  Future<void> toggleUnsafeZone(String id, bool isActive) async {
    await _zones.doc(id).update({'isActive': isActive});
  }

  // ════════════════════════════════════════════
  // INCIDENT REPORTS
  // ════════════════════════════════════════════

  /// Stream all incidents in real time, newest first.
  Stream<List<IncidentReport>> streamIncidents() {
    return _incidents
        .orderBy('reportedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(IncidentReport.fromFirestore).toList());
  }

  /// Submit a new incident report (tourist app).
  Future<void> submitIncident(IncidentReport incident) async {
    await _incidents.add(incident.toFirestore());
  }

  /// Update incident status (police dashboard).
  Future<void> updateIncidentStatus(String id, String status) async {
    await _incidents.doc(id).update({'status': status});
  }

  // ════════════════════════════════════════════
  // SAFETY ALERTS
  // ════════════════════════════════════════════

  /// Stream all active alerts, newest first.
  Stream<List<SafetyAlert>> streamAlerts() {
    return _alerts
        .where('isActive', isEqualTo: true)
        .orderBy('issuedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(SafetyAlert.fromFirestore).toList());
  }

  /// Broadcast a new alert (police dashboard).
  Future<void> broadcastAlert(SafetyAlert alert) async {
    await _alerts.add(alert.toFirestore());
  }

  /// Deactivate an alert.
  Future<void> deactivateAlert(String id) async {
    await _alerts.doc(id).update({'isActive': false});
  }

  // ════════════════════════════════════════════
  // TOURIST LIVE LOCATIONS
  // ════════════════════════════════════════════

  /// Stream all tourist locations sharing with authorities.
  Stream<List<TouristLocation>> streamTouristLocations() {
    return _touristLocations
        .snapshots()
        .map((snap) => snap.docs.map(TouristLocation.fromFirestore).toList());
  }

  /// Upsert a tourist's live location. Uses the session ID as the document ID.
  Future<void> updateTouristLocation(String sessionId, TouristLocation loc) async {
    await _touristLocations.doc(sessionId).set(loc.toFirestore());
  }

  /// Remove a tourist's location when they stop sharing.
  Future<void> removeTouristLocation(String sessionId) async {
    await _touristLocations.doc(sessionId).delete();
  }

  // ════════════════════════════════════════════
  // CHATBOT CONFIG
  // ════════════════════════════════════════════

  /// Get the current custom chatbot instructions.
  Future<String?> getChatbotInstructions() async {
    final doc = await _chatbotConfig.doc('main').get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      return data?['customInstructions'] as String?;
    }
    return null;
  }

  /// Stream chatbot instructions for real-time updates.
  Stream<String?> streamChatbotInstructions() {
    return _chatbotConfig.doc('main').snapshots().map((doc) {
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        return data?['customInstructions'] as String?;
      }
      return null;
    });
  }

  /// Update chatbot instructions (police dashboard).
  Future<void> updateChatbotInstructions(String instructions) async {
    await _chatbotConfig.doc('main').set({
      'customInstructions': instructions,
      'updatedAt': Timestamp.now(),
    });
  }
}
