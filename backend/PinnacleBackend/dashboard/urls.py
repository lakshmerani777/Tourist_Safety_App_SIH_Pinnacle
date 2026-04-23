from django.urls import path
from . import views

app_name = 'dashboard'

urlpatterns = [
    # Pages
    path('', views.login_view, name='login'),
    path('logout/', views.logout_view, name='logout'),
    path('map/', views.map_view, name='map'),
    path('alerts/', views.alerts_view, name='alerts'),
    path('incidents/', views.incidents_view, name='incidents'),
    path('ai-config/', views.ai_config_view, name='ai_config'),
    path('sos/', views.sos_view, name='sos'),

    # Zone APIs
    path('api/zones/create/', views.api_zone_create, name='api_zone_create'),
    path('api/zones/<str:zone_id>/update/', views.api_zone_update, name='api_zone_update'),
    path('api/zones/<str:zone_id>/delete/', views.api_zone_delete, name='api_zone_delete'),

    # Alert APIs
    path('api/alerts/create/', views.api_alert_create, name='api_alert_create'),
    path('api/alerts/<str:alert_id>/deactivate/', views.api_alert_deactivate, name='api_alert_deactivate'),
    path('api/alerts/<str:alert_id>/activate/', views.api_alert_activate, name='api_alert_activate'),
    path('api/alerts/<str:alert_id>/delete/', views.api_alert_delete, name='api_alert_delete'),

    # Incident APIs
    path('api/incidents/<str:incident_id>/status/', views.api_incident_status, name='api_incident_status'),

    # SOS APIs
    path('api/sos/poll/', views.api_sos_poll, name='api_sos_poll'),
    path('api/sos/<str:incident_id>/acknowledge/', views.api_sos_acknowledge, name='api_sos_acknowledge'),
    path('api/sos/<str:incident_id>/status/', views.api_sos_status, name='api_sos_status'),

    # AI Config APIs
    path('api/ai-config/save/', views.api_ai_config_save, name='api_ai_config_save'),

    # Location Anomaly APIs
    path('api/anomalies/', views.api_anomalies_json, name='api_anomalies_json'),
    path('api/anomalies/<str:session_id>/acknowledge/', views.api_acknowledge_anomaly, name='api_acknowledge_anomaly'),

    # Tourist Profile APIs
    path('api/tourists/<str:user_id>/profile/', views.api_tourist_profile, name='api_tourist_profile'),
    path('api/tourists/profile-by-email/<str:email>/', views.api_tourist_profile_by_email, name='api_tourist_profile_by_email'),
]
