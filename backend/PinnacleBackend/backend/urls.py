from django.urls import path

from backend import views

urlpatterns = [
    path('', views.HelloView.as_view()),
    path('api/auth/register/', views.RegisterView.as_view()),
    path('api/auth/signin/', views.SignInView.as_view()),
]
