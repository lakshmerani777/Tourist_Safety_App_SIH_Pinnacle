"""
Firebase Admin SDK wrapper for Firestore CRUD operations.
This service mirrors the Flutter app's FirestoreService, ensuring
both the dashboard and the app operate on identical data structures.
"""

import os
from datetime import datetime, timezone

import firebase_admin
from firebase_admin import credentials, firestore

# ─── Initialise Firebase Admin SDK ───────────────────────────────
_BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_CRED_PATH = os.path.join(_BASE_DIR, 'firebase-service-account.json')

if not firebase_admin._apps:
    if os.path.exists(_CRED_PATH):
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
