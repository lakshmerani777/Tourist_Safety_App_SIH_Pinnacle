import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

/// Represents an unsafe zone drawn by police on the dashboard.
class UnsafeZone {
  final String id;
  final String name;
  final String description;
  final String severity; // LOW, MEDIUM, HIGH
  final List<LatLng> polygon; // List of polygon vertices
  final DateTime createdAt;
  final bool isActive;

  const UnsafeZone({
    required this.id,
    required this.name,
    required this.description,
    required this.severity,
    required this.polygon,
    required this.createdAt,
    this.isActive = true,
  });

  factory UnsafeZone.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final points = (data['polygon'] as List<dynamic>? ?? []).map((p) {
      final point = p as Map<String, dynamic>;
      return LatLng(
        (point['lat'] as num).toDouble(),
        (point['lng'] as num).toDouble(),
      );
    }).toList();

    return UnsafeZone(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      severity: data['severity'] ?? 'MEDIUM',
      polygon: points,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'severity': severity,
      'polygon': polygon.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}

/// Represents an incident reported by a tourist or created by police.
class IncidentReport {
  final String id;
  final String type;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final DateTime reportedAt;
  final String reportedBy; // 'tourist' or 'police'
  final String? touristName;
  final String? touristNationality;
  final String? mediaUrl;
  final String status; // 'pending', 'reviewed', 'resolved'

  const IncidentReport({
    required this.id,
    required this.type,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.reportedAt,
    this.reportedBy = 'tourist',
    this.touristName,
    this.touristNationality,
    this.mediaUrl,
    this.status = 'pending',
  });

  factory IncidentReport.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return IncidentReport(
      id: doc.id,
      type: data['type'] ?? '',
      description: data['description'] ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      address: data['address'] ?? '',
      reportedAt: (data['reportedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      reportedBy: data['reportedBy'] ?? 'tourist',
      touristName: data['touristName'],
      touristNationality: data['touristNationality'],
      mediaUrl: data['mediaUrl'],
      status: data['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'reportedAt': Timestamp.fromDate(reportedAt),
      'reportedBy': reportedBy,
      'touristName': touristName,
      'touristNationality': touristNationality,
      'mediaUrl': mediaUrl,
      'status': status,
    };
  }
}

/// Alert broadcast by police to tourists.
class SafetyAlert {
  final String id;
  final String title;
  final String description;
  final String severity; // LOW, MEDIUM, HIGH
  final String location; // Human-readable location string
  final List<LatLng>? geofence; // Optional geofence polygon for targeted alerts
  final List<String>? targetNationalities; // null = all
  final String? targetGender; // null = all, 'male', 'female'
  final DateTime issuedAt;
  final bool isActive;
  final String helplineNumber;

  const SafetyAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.severity,
    required this.location,
    this.geofence,
    this.targetNationalities,
    this.targetGender,
    required this.issuedAt,
    this.isActive = true,
    this.helplineNumber = '1363',
  });

  factory SafetyAlert.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<LatLng>? geofence;
    if (data['geofence'] != null) {
      geofence = (data['geofence'] as List<dynamic>).map((p) {
        final point = p as Map<String, dynamic>;
        return LatLng(
          (point['lat'] as num).toDouble(),
          (point['lng'] as num).toDouble(),
        );
      }).toList();
    }

    return SafetyAlert(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      severity: data['severity'] ?? 'MEDIUM',
      location: data['location'] ?? '',
      geofence: geofence,
      targetNationalities: (data['targetNationalities'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      targetGender: data['targetGender'],
      issuedAt: (data['issuedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
      helplineNumber: data['helplineNumber'] ?? '1363',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'severity': severity,
      'location': location,
      'geofence': geofence?.map((p) => {'lat': p.latitude, 'lng': p.longitude}).toList(),
      'targetNationalities': targetNationalities,
      'targetGender': targetGender,
      'issuedAt': Timestamp.fromDate(issuedAt),
      'isActive': isActive,
      'helplineNumber': helplineNumber,
    };
  }
}

/// Live tourist location for authority tracking.
class TouristLocation {
  final String id;
  final String name;
  final String? nationality;
  final String? gender;
  final double latitude;
  final double longitude;
  final DateTime lastUpdated;

  const TouristLocation({
    required this.id,
    required this.name,
    this.nationality,
    this.gender,
    required this.latitude,
    required this.longitude,
    required this.lastUpdated,
  });

  factory TouristLocation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TouristLocation(
      id: doc.id,
      name: data['name'] ?? 'Tourist',
      nationality: data['nationality'],
      gender: data['gender'],
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'nationality': nationality,
      'gender': gender,
      'latitude': latitude,
      'longitude': longitude,
      'lastUpdated': Timestamp.fromDate(DateTime.now()),
    };
  }
}
