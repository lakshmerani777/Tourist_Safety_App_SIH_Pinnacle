from django.urls import path

from backend import views

urlpatterns = [
    path('', views.HelloView.as_view()),
    path('api/auth/register/', views.RegisterView.as_view()),
    path('api/auth/signin/', views.SignInView.as_view()),
    path('api/auth/logout/', views.LogoutView.as_view()),
    path('api/auth/me/', views.ProfileView.as_view()),
    path('api/onboarding/', views.OnboardingView.as_view()),
    path('api/sos/', views.SOSView.as_view()),
    path('api/config/maps-key/', views.MapsConfigView.as_view()),
    path('api/digital-id/issue/', views.IssueCredentialView.as_view()),
    path('api/digital-id/me/', views.GetCredentialView.as_view()),
    path('api/digital-id/verify/<str:credential_id_hex>/', views.VerifyCredentialView.as_view()),
]
