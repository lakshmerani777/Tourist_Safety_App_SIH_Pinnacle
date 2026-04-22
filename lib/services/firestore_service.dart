import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/firestore_models.dart';

/// Central service for all Firestore reads/writes used by both
/// the tourist app and the police dashboard.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─── Collection References ───
  CollectionReference get _zones => _db.collection('unsafe_zones');
  CollectionReference get _incidents => _db.collection('incidents');
  CollectionReference get _alerts => _db.collection('alerts');
  CollectionReference get _touristLocations => _db.collection('tourist_locations');
  CollectionReference get _chatbotConfig => _db.collection('chatbot_config');

  /// Upload an image to Firebase Storage and return the download URL.
  Future<String> uploadImage(File file, String path) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }

  // ════════════════════════════════════════════
  // UNSAFE ZONES
  // ════════════════════════════════════════════

  /// Stream all active unsafe zones in real time.
  /// All filtering and sorting done client-side to avoid Firestore index issues.
  Stream<List<UnsafeZone>> streamUnsafeZones() {
    return _zones
        .snapshots()
        .map((snap) {
          final zones = <UnsafeZone>[];
          for (final doc in snap.docs) {
            try {
              final zone = UnsafeZone.fromFirestore(doc);
              if (zone.isActive) zones.add(zone);
            } catch (_) {}
          }
          zones.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return zones;
        });
  }


  /// Update zone metadata (name, description, severity).
  Future<void> updateUnsafeZone(String id, {String? name, String? description, String? severity}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (description != null) updates['description'] = description;
    if (severity != null) updates['severity'] = severity;
    if (updates.isNotEmpty) await _zones.doc(id).update(updates);
  }

  // ════════════════════════════════════════════
  // INCIDENT REPORTS
  // ════════════════════════════════════════════

  /// Stream all incidents in real time, newest first.
  Stream<List<IncidentReport>> streamIncidents() {
    return _incidents
        .snapshots()
        .map((snap) {
          final incidents = <IncidentReport>[];
          for (final doc in snap.docs) {
            try {
              incidents.add(IncidentReport.fromFirestore(doc));
            } catch (_) {}
          }
          incidents.sort((a, b) => b.reportedAt.compareTo(a.reportedAt));
          return incidents;
        });
  }

  /// Submit a new incident report (tourist app).
  Future<void> submitIncident(IncidentReport incident) async {
    await _incidents.add(incident.toFirestore());
  }


  // ════════════════════════════════════════════
  // SAFETY ALERTS
  // ════════════════════════════════════════════

  /// Stream all active alerts, newest first.
  /// All filtering and sorting done client-side to avoid Firestore index issues.
  Stream<List<SafetyAlert>> streamAlerts() {
    return _alerts
        .snapshots()
        .map((snap) {
          final alerts = <SafetyAlert>[];
          for (final doc in snap.docs) {
            try {
              final alert = SafetyAlert.fromFirestore(doc);
              if (alert.isActive) alerts.add(alert);
            } catch (e) {
              // Log malformed documents for debugging
              debugPrint('⚠️ Failed to parse alert doc ${doc.id}: $e');
            }
          }
          alerts.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
          return alerts;
        });
  }


  /// Stream ALL alerts (active and inactive), newest first.
  Stream<List<SafetyAlert>> streamAllAlerts() {
    return _alerts
        .snapshots()
        .map((snap) {
          final alerts = <SafetyAlert>[];
          for (final doc in snap.docs) {
            try {
              alerts.add(SafetyAlert.fromFirestore(doc));
            } catch (_) {}
          }
          alerts.sort((a, b) => b.issuedAt.compareTo(a.issuedAt));
          return alerts;
        });
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

  // ════════════════════════════════════════════
  // LOCATION ANOMALY DETECTION
  // ════════════════════════════════════════════

  /// Flag a tourist's location as anomalous (GPS stopped updating).
  Future<void> flagLocationAnomaly(String sessionId) async {
    await _touristLocations.doc(sessionId).update({
      'status': 'anomaly_flagged',
      'anomalyFlaggedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  /// Clear anomaly flag when location resumes updating.
  Future<void> clearLocationAnomaly(String sessionId) async {
    await _touristLocations.doc(sessionId).update({
      'status': 'active',
      'anomalyFlaggedAt': null,
    });
  }

  // ════════════════════════════════════════════
  // SOS EMERGENCY
  // ════════════════════════════════════════════

  /// Submit an SOS alert directly to Firestore for dashboard real-time pickup.
  Future<void> submitSOSToFirestore({
    required String touristName,
    required String touristNationality,
    required double latitude,
    required double longitude,
    required String address,
    String phone = '',
  }) async {
    await _incidents.add({
      'type': 'SOS',
      'description': 'SOS Emergency Alert triggered by tourist',
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'reportedAt': Timestamp.fromDate(DateTime.now()),
      'reportedBy': 'tourist',
      'touristName': touristName,
      'touristNationality': touristNationality,
      'touristPhone': phone,
      'status': 'pending',
      'isSOS': true,
      'dashboardAcknowledged': false,
    });
  }


}
