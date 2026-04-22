"""
Police Security Dashboard views.
All data is stored in and retrieved from Firebase Firestore.
"""

import json
from functools import wraps

from django.http import JsonResponse
from django.shortcuts import render, redirect
from django.views.decorators.http import require_POST, require_GET

from . import firebase_admin_service as fs

# ─── Access Code ─────────────────────────────────────────────────
DASHBOARD_ACCESS_CODE = 'POLICE2026'


def dashboard_login_required(view_func):
    """Simple session-based access gate for the dashboard."""
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        if not request.session.get('dashboard_authenticated'):
            return redirect('dashboard:login')
        return view_func(request, *args, **kwargs)
    return wrapper


# ════════════════════════════════════════════════════════════════
# LOGIN
# ════════════════════════════════════════════════════════════════

def login_view(request):
    """Dashboard login with access code."""
    error = None
    if request.method == 'POST':
        code = request.POST.get('access_code', '').strip()
        if code == DASHBOARD_ACCESS_CODE:
            request.session['dashboard_authenticated'] = True
            return redirect('dashboard:map')
        else:
            error = 'Invalid access code. Please try again.'
    return render(request, 'dashboard/login.html', {'error': error})


def logout_view(request):
    """Clear dashboard session."""
    request.session.pop('dashboard_authenticated', None)
    return redirect('dashboard:login')


# ════════════════════════════════════════════════════════════════
# MAP VIEW (High Risk Zones)
# ════════════════════════════════════════════════════════════════

@dashboard_login_required
def map_view(request):
    """Interactive map with high-risk zone management."""
    zones = fs.get_unsafe_zones(active_only=False)
    tourist_locations = fs.get_tourist_locations()
    anomaly_count = fs.get_anomaly_count()
    return render(request, 'dashboard/map.html', {
        'zones_json': json.dumps(zones, default=str),
        'tourist_locations_json': json.dumps(tourist_locations, default=str),
        'anomaly_count': anomaly_count,
        'active_tab': 'map',
    })


@require_POST
@dashboard_login_required
def api_zone_create(request):
    """API: Create a new high-risk zone."""
    try:
        data = json.loads(request.body)
        fs.add_unsafe_zone(
            name=data['name'],
            description=data.get('description', ''),
            severity=data.get('severity', 'HIGH'),
            polygon_points=data['polygon'],
        )
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_POST
@dashboard_login_required
def api_zone_update(request, zone_id):
    """API: Update an existing zone."""
    try:
        data = json.loads(request.body)
        fs.update_unsafe_zone(zone_id, **data)
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_POST
@dashboard_login_required
def api_zone_delete(request, zone_id):
    """API: Delete a zone."""
    try:
        fs.delete_unsafe_zone(zone_id)
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


# ════════════════════════════════════════════════════════════════
# ALERT CENTER
# ════════════════════════════════════════════════════════════════

@dashboard_login_required
def alerts_view(request):
    """Alert history and compose interface."""
    alerts = fs.get_alerts(active_only=False)
    return render(request, 'dashboard/alerts.html', {
        'alerts': alerts,
        'active_tab': 'alerts',
    })


@require_POST
@dashboard_login_required
def api_alert_create(request):
    """API: Broadcast a new alert."""
    try:
        data = json.loads(request.body)
        fs.broadcast_alert(
            title=data['title'],
            description=data['description'],
            severity=data.get('severity', 'MEDIUM'),
            location=data.get('location', ''),
            helpline=data.get('helplineNumber', '1363'),
        )
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_POST
@dashboard_login_required
def api_alert_deactivate(request, alert_id):
    """API: Deactivate an alert."""
    try:
        fs.deactivate_alert(alert_id)
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_POST
@dashboard_login_required
def api_alert_activate(request, alert_id):
    """API: Re-activate an alert."""
    try:
        fs.activate_alert(alert_id)
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_POST
@dashboard_login_required
def api_alert_delete(request, alert_id):
    """API: Delete an alert permanently."""
    try:
        fs.delete_alert(alert_id)
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


# ════════════════════════════════════════════════════════════════
# INCIDENT MANAGER
# ════════════════════════════════════════════════════════════════

@dashboard_login_required
def incidents_view(request):
    """Incident reports list with status management."""
    incidents = fs.get_incidents()
    return render(request, 'dashboard/incidents.html', {
        'incidents': incidents,
        'active_tab': 'incidents',
    })


@require_POST
@dashboard_login_required
def api_incident_status(request, incident_id):
    """API: Update incident status."""
    try:
        data = json.loads(request.body)
        fs.update_incident_status(incident_id, data['status'])
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


# ════════════════════════════════════════════════════════════════
# AI CONFIG
# ════════════════════════════════════════════════════════════════

@dashboard_login_required
def ai_config_view(request):
    """Gemini chatbot system prompt editor."""
    custom_instructions = fs.get_chatbot_instructions()
    # The base system prompt is shown read-only for reference
    base_prompt = _get_base_prompt()
    return render(request, 'dashboard/ai_config.html', {
        'base_prompt': base_prompt,
        'custom_instructions': custom_instructions or '',
        'active_tab': 'ai_config',
    })


@require_POST
@dashboard_login_required
def api_ai_config_save(request):
    """API: Save custom chatbot instructions."""
    try:
        data = json.loads(request.body)
        fs.update_chatbot_instructions(data['instructions'])
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


# ════════════════════════════════════════════════════════════════
# LOCATION ANOMALY ENDPOINTS
# ════════════════════════════════════════════════════════════════

@require_GET
@dashboard_login_required
def api_anomalies_json(request):
    """API: Return current tourist locations + anomaly data as JSON (for polling)."""
    try:
        locations = fs.get_tourist_locations()
        anomaly_count = fs.get_anomaly_count()
        return JsonResponse({
            'locations': locations,
            'anomaly_count': anomaly_count,
        })
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_POST
@dashboard_login_required
def api_acknowledge_anomaly(request, session_id):
    """API: Acknowledge a location anomaly."""
    try:
        fs.acknowledge_anomaly(session_id)
        return JsonResponse({'status': 'ok'})
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


@require_GET
@dashboard_login_required
def api_tourist_profile(request, user_id):
    """API: Get tourist profile details."""
    try:
        profile = fs.get_tourist_profile(user_id)
        if profile:
            return JsonResponse({'status': 'ok', 'profile': profile})
        else:
            return JsonResponse({'error': 'Profile not found'}, status=404)
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)


# ─── Helpers ─────────────────────────────────────────────────────

def _get_base_prompt():
    """Return the base system prompt used by GeminiChatService."""
    return """You are a Tourist Safety Assistant integrated into a mobile safety application.

Your primary objective is to help tourists stay safe by providing accurate, practical, and location-aware guidance.

You must prioritize:
1. User safety
2. Clarity of instructions
3. Actionable advice
4. Calm and reassuring tone

---

CORE RESPONSIBILITIES:

1. SAFETY GUIDANCE
- Provide safety tips based on user queries.
- Warn users about risky situations (e.g., unsafe areas, scams, late-night travel risks).
- Suggest safer alternatives whenever possible.

2. EMERGENCY SUPPORT
- If a user expresses distress, danger, or fear:
  - Immediately advise them to use the SOS button in the app.
  - Provide step-by-step actions (e.g., move to a crowded area, call local authorities).
  - Keep instructions short and clear.

3. LOCATION-AWARE ASSISTANCE
- When relevant, suggest nearby:
  - Police stations
  - Hospitals
  - Pharmacies
  - Safe public areas
- If exact data is unavailable, give general guidance (e.g., "look for well-lit main roads").

4. TOURIST HELP
- Answer general travel safety questions:
  - Transport safety
  - Local customs
  - Safe travel practices
- Provide culturally respectful advice.

---

TONE & STYLE:
- Calm, clear, and professional
- Never alarmist or overly dramatic
- Avoid long paragraphs
- Use structured responses when helpful (bullets or steps)

---

RESPONSE FORMAT:
When giving advice:
- Start with a short direct answer
- Then provide 2–5 actionable steps

---

WHAT YOU MUST DO:
- Encourage safe behavior
- Suggest verified services (police, hospitals)
- Recommend using in-app SOS in emergencies
- Keep responses concise and useful

---

WHAT YOU MUST NOT DO:
- Do NOT provide medical diagnosis
- Do NOT give legal advice
- Do NOT guess unknown facts
- Do NOT provide dangerous or risky instructions
- Do NOT say "I am an AI model"

---

GOAL:
Help the user feel safer, make better decisions, and act quickly in risky situations.

USER LOCATION: MUMBAI"""
