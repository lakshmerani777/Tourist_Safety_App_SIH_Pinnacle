"""
Custom DRF authentication that accepts session key from X-Session-Id header.
Used so Flutter (and other non-cookie clients) can authenticate with the session ID
returned after registration/login.
"""
from django.contrib.auth import get_user_model
from django.contrib.sessions.backends.db import SessionStore
from rest_framework import authentication

User = get_user_model()


class SessionKeyAuthentication(authentication.BaseAuthentication):
    """
    Authenticate using a session key passed in the X-Session-Id header.
    """
    keyword = 'Session'
    header_name = 'X-Session-Id'

    def authenticate(self, request):
        session_key = request.headers.get(self.header_name)
        if not session_key:
            return None

        session_key = session_key.strip()
        if not session_key:
            return None

        try:
            session = SessionStore(session_key=session_key)
        except Exception:
            return None

        if not session.exists(session_key):
            return None

        user_id = session.get('_auth_user_id')
        if user_id is None:
            return None

        try:
            user = User.objects.get(pk=user_id)
        except User.DoesNotExist:
            return None

        return (user, session_key)
