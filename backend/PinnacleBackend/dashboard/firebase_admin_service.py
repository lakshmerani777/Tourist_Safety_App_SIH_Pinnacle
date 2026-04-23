"""
Firebase Admin SDK wrapper for Firestore CRUD operations.
This service mirrors the Flutter app's FirestoreService, ensuring
both the dashboard and the app operate on identical data structures.
"""

import os
from datetime import datetime, timezone

import json
import firebase_admin
from firebase_admin import credentials, firestore

# ─── Initialise Firebase Admin SDK ───────────────────────────────
_BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_CRED_PATH = os.path.join(_BASE_DIR, 'firebase-service-account.json')

if not firebase_admin._apps:
    # Try environment variable first (for Vercel/Production)
    cred_json = os.environ.get('FIREBASE_SERVICE_ACCOUNT_JSON')
    if cred_json:
        try:
            cred_dict = json.loads(cred_json)
            cred = credentials.Certificate(cred_dict)
            firebase_admin.initialize_app(cred)
        except Exception:
            firebase_admin.initialize_app()
    elif os.path.exists(_CRED_PATH):
        cred = credentials.Certificate(_CRED_PATH)
        firebase_admin.initialize_app(cred)
    else:
        # Fallback: try Application Default Credentials
        firebase_admin.initialize_app()

db = firestore.client()


# ════════════════════════════════════════════════════════════════
# UNSAFE ZONES
# ════════════════════════════════════════════════════════════════

def get_unsafe_zones(active_only=True):
    """Return all unsafe zones, optionally filtered by active status."""
    ref = db.collection('unsafe_zones')
    if active_only:
        ref = ref.where('isActive', '==', True)
    docs = ref.order_by('createdAt', direction=firestore.Query.DESCENDING).stream()
    zones = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        zones.append(data)
    return zones


def add_unsafe_zone(name, description, severity, polygon_points):
    """
    Create a new unsafe zone.
    polygon_points: list of {'lat': float, 'lng': float}
    """
    db.collection('unsafe_zones').add({
        'name': name,
        'description': description,
        'severity': severity,
        'polygon': polygon_points,
        'isActive': True,
        'createdAt': firestore.SERVER_TIMESTAMP,
    })


def update_unsafe_zone(zone_id, **kwargs):
    """Update zone fields (name, description, severity, isActive, polygon)."""
    allowed = {'name', 'description', 'severity', 'isActive', 'polygon'}
    updates = {k: v for k, v in kwargs.items() if k in allowed}
    if updates:
        db.collection('unsafe_zones').document(zone_id).update(updates)


def delete_unsafe_zone(zone_id):
    """Permanently delete a zone."""
    db.collection('unsafe_zones').document(zone_id).delete()


# ════════════════════════════════════════════════════════════════
# SAFETY ALERTS
# ════════════════════════════════════════════════════════════════

def get_alerts(active_only=False):
    """Return all alerts. Set active_only=True to filter."""
    ref = db.collection('alerts')
    if active_only:
        ref = ref.where('isActive', '==', True)
    docs = ref.order_by('issuedAt', direction=firestore.Query.DESCENDING).stream()
    alerts = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        # Convert Timestamp to datetime for template rendering
        if data.get('issuedAt'):
            data['issuedAt'] = data['issuedAt'].isoformat() if hasattr(data['issuedAt'], 'isoformat') else str(data['issuedAt'])
        alerts.append(data)
    return alerts


def broadcast_alert(title, description, severity, location='', helpline='1363'):
    """Create a new safety alert visible to all app users."""
    db.collection('alerts').add({
        'title': title,
        'description': description,
        'severity': severity,
        'location': location,
        'isActive': True,
        'issuedAt': firestore.SERVER_TIMESTAMP,
        'helplineNumber': helpline,
        'geofence': None,
        'targetNationalities': None,
        'targetGender': None,
    })


def deactivate_alert(alert_id):
    """Mark an alert as inactive."""
    db.collection('alerts').document(alert_id).update({'isActive': False})


def activate_alert(alert_id):
    """Re-activate an alert."""
    db.collection('alerts').document(alert_id).update({'isActive': True})


def delete_alert(alert_id):
    """Permanently delete an alert."""
    db.collection('alerts').document(alert_id).delete()


# ════════════════════════════════════════════════════════════════
# INCIDENT REPORTS
# ════════════════════════════════════════════════════════════════

def get_incidents():
    """Return all incident reports, newest first."""
    docs = db.collection('incidents').order_by(
        'reportedAt', direction=firestore.Query.DESCENDING
    ).stream()
    incidents = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        if data.get('reportedAt'):
            data['reportedAt'] = data['reportedAt'].isoformat() if hasattr(data['reportedAt'], 'isoformat') else str(data['reportedAt'])
        incidents.append(data)
    return incidents


def update_incident_status(incident_id, status):
    """Update incident status: 'pending' → 'reviewed' → 'resolved'."""
    db.collection('incidents').document(incident_id).update({'status': status})


# ════════════════════════════════════════════════════════════════
# CHATBOT CONFIG
# ════════════════════════════════════════════════════════════════

def get_chatbot_instructions():
    """Get custom chatbot instructions from Firestore."""
    doc = db.collection('chatbot_config').document('main').get()
    if doc.exists:
        return doc.to_dict().get('customInstructions', '')
    return ''


def update_chatbot_instructions(instructions):
    """Update custom chatbot instructions in Firestore."""
    db.collection('chatbot_config').document('main').set({
        'customInstructions': instructions,
        'updatedAt': firestore.SERVER_TIMESTAMP,
    })


# ════════════════════════════════════════════════════════════════
# TOURIST PROFILES
# ════════════════════════════════════════════════════════════════

def save_tourist_profile(user_id, profile_data):
    """Save or update a tourist's onboarding profile in Firestore."""
    profile_data['updatedAt'] = firestore.SERVER_TIMESTAMP
    db.collection('tourist_profiles').document(str(user_id)).set(profile_data, merge=True)


def get_tourist_profile(user_id):
    """Return tourist profile dict or None if not found."""
    doc = db.collection('tourist_profiles').document(str(user_id)).get()
    if doc.exists:
        data = doc.to_dict()
        data['id'] = doc.id
        return data
    return None


def get_tourist_profile_by_email(email):
    """
    Return tourist profile dict by looking up the Django user with the given email.
    Returns None if user or profile not found.
    """
    from django.contrib.auth import get_user_model
    User = get_user_model()
    try:
        user = User.objects.get(email=email)
        return get_tourist_profile(user.id)
    except User.DoesNotExist:
        # Try username lookup as well since we often set username=email
        try:
            user = User.objects.get(username=email)
            return get_tourist_profile(user.id)
        except User.DoesNotExist:
            return None


# ════════════════════════════════════════════════════════════════
# SOS INCIDENTS
# ════════════════════════════════════════════════════════════════

def create_sos_incident(tourist_name, tourist_nationality, latitude, longitude, address, user_id=''):
    """Create an SOS incident in the incidents collection and return its ID."""
    _timestamp, doc_ref = db.collection('incidents').add({
        'type': 'SOS',
        'description': 'SOS Emergency Alert triggered by tourist',
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'reportedAt': firestore.SERVER_TIMESTAMP,
        'reportedBy': user_id or 'tourist',
        'touristName': tourist_name,
        'touristNationality': tourist_nationality,
        'status': 'pending',
        'isSOS': True,
    })
    return doc_ref.id


def get_sos_incidents():
    """Return all SOS incidents, newest first."""
    docs = db.collection('incidents').where('isSOS', '==', True).stream()
    incidents = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        if data.get('reportedAt'):
            data['reportedAt'] = data['reportedAt'].isoformat() if hasattr(data['reportedAt'], 'isoformat') else str(data['reportedAt'])
        incidents.append(data)
    # Sort client-side to avoid needing a composite index
    incidents.sort(key=lambda x: x.get('reportedAt', ''), reverse=True)
    return incidents


def get_new_sos_incidents(last_check_ids=None):
    """Return SOS incidents that haven't been acknowledged by the dashboard."""
    docs = db.collection('incidents').where('isSOS', '==', True).stream()
    incidents = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        # Only return un-acknowledged SOS calls
        if not data.get('dashboardAcknowledged', False):
            if data.get('reportedAt'):
                data['reportedAt'] = data['reportedAt'].isoformat() if hasattr(data['reportedAt'], 'isoformat') else str(data['reportedAt'])
            incidents.append(data)
    incidents.sort(key=lambda x: x.get('reportedAt', ''), reverse=True)
    return incidents


def acknowledge_sos(incident_id):
    """Mark an SOS incident as acknowledged by the dashboard."""
    db.collection('incidents').document(incident_id).update({
        'dashboardAcknowledged': True,
    })


def update_sos_status(incident_id, status):
    """Update SOS status: 'pending' → 'responding' → 'resolved'."""
    db.collection('incidents').document(incident_id).update({'status': status})


# ════════════════════════════════════════════════════════════════
# TOURIST LOCATIONS & ANOMALY DETECTION
# ════════════════════════════════════════════════════════════════

def update_tourist_location(session_id, name, nationality, latitude, longitude):
    """Upsert a tourist's live location."""
    db.collection('tourist_locations').document(session_id).set({
        'id': session_id,
        'name': name,
        'nationality': nationality,
        'latitude': latitude,
        'longitude': longitude,
        'lastUpdated': firestore.SERVER_TIMESTAMP,
    }, merge=True)


def remove_tourist_location(session_id):
    """Remove a tourist's live location entry."""
    db.collection('tourist_locations').document(session_id).delete()


def get_tourist_locations():
    """Return all tourist locations currently sharing."""
    docs = db.collection('tourist_locations').stream()
    locations = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        if data.get('lastUpdated'):
            data['lastUpdated'] = data['lastUpdated'].isoformat() if hasattr(data['lastUpdated'], 'isoformat') else str(data['lastUpdated'])
        if data.get('lastMovedAt'):
            data['lastMovedAt'] = data['lastMovedAt'].isoformat() if hasattr(data['lastMovedAt'], 'isoformat') else str(data['lastMovedAt'])
        if data.get('anomalyFlaggedAt'):
            data['anomalyFlaggedAt'] = data['anomalyFlaggedAt'].isoformat() if hasattr(data['anomalyFlaggedAt'], 'isoformat') else str(data['anomalyFlaggedAt'])
        locations.append(data)
    return locations


def get_anomaly_locations():
    """Return tourist locations with anomaly_flagged status."""
    docs = db.collection('tourist_locations').where(
        'status', '==', 'anomaly_flagged'
    ).stream()
    anomalies = []
    for doc in docs:
        data = doc.to_dict()
        data['id'] = doc.id
        if data.get('lastUpdated'):
            data['lastUpdated'] = data['lastUpdated'].isoformat() if hasattr(data['lastUpdated'], 'isoformat') else str(data['lastUpdated'])
        if data.get('anomalyFlaggedAt'):
            data['anomalyFlaggedAt'] = data['anomalyFlaggedAt'].isoformat() if hasattr(data['anomalyFlaggedAt'], 'isoformat') else str(data['anomalyFlaggedAt'])
        anomalies.append(data)
    return anomalies


def get_anomaly_count():
    """Return the count of anomaly-flagged tourist locations."""
    docs = db.collection('tourist_locations').where(
        'status', '==', 'anomaly_flagged'
    ).stream()
    return sum(1 for _ in docs)


def acknowledge_anomaly(session_id):
    """Acknowledge an anomaly flag on a tourist location."""
    db.collection('tourist_locations').document(session_id).update({
        'status': 'acknowledged',
    })
