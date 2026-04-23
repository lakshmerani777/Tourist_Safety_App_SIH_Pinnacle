import re
from datetime import datetime
from django.conf import settings
from django.contrib.auth import authenticate, get_user_model, login
from django.contrib.auth import logout as auth_logout
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.http import JsonResponse
from rest_framework import status
from rest_framework.views import APIView
from dashboard.firebase_admin_service import (
    save_tourist_profile,
    get_tourist_profile,
    create_sos_incident,
    db,
    firestore,
)
from .models import TouristDigitalID
from .blockchain_service import get_blockchain_service

User = get_user_model()

EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')


class HelloView(APIView):
    def get(self, request):
        return JsonResponse({'message': 'Hello, world!'})


class MapsConfigView(APIView):
    """
    GET /api/config/maps-key — returns the Google Maps API key for the app.
    Key is read from backend .env (GOOGLE_MAPS_API_KEY). Optional: restrict with auth.
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request):
        api_key = getattr(settings, 'GOOGLE_MAPS_API_KEY', '') or ''
        return JsonResponse({'mapsApiKey': api_key})


class RegisterView(APIView):
    """
    POST only. Creates a user and logs them in; returns session_id and user info.
    Body: full_name, email, password (optional: confirm_password).
    """
    authentication_classes = []  # No auth required for registration
    permission_classes = []

    def post(self, request):
        data = request.data if hasattr(request, 'data') and request.data is not None else {}
        if not isinstance(data, dict):
            data = {}

        full_name = (data.get('full_name') or '').strip()
        email = (data.get('email') or '').strip().lower()
        password = data.get('password') or ''
        confirm_password = data.get('confirm_password') or ''

        # Required fields
        if not full_name:
            return JsonResponse(
                {'error': 'Full name is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not email:
            return JsonResponse(
                {'error': 'Email is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if not password:
            return JsonResponse(
                {'error': 'Password is required.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Email format
        if not EMAIL_REGEX.match(email):
            return JsonResponse(
                {'error': 'Enter a valid email address.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Password match if confirm provided
        if confirm_password and password != confirm_password:
            return JsonResponse(
                {'error': 'Passwords do not match.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Django password validators
        try:
            validate_password(password)
        except ValidationError as e:
            return JsonResponse(
                {'error': e.messages[0] if e.messages else 'Invalid password.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Email uniqueness (use as username)
        if User.objects.filter(email=email).exists():
            return JsonResponse(
                {'error': 'A user with this email already exists.'},
                status=status.HTTP_400_BAD_REQUEST
            )
        if User.objects.filter(username=email).exists():
            return JsonResponse(
                {'error': 'A user with this email already exists.'},
                status=status.HTTP_400_BAD_REQUEST
            )

        # Create user: username=email for simplicity
        user = User.objects.create_user(
            username=email,
            email=email,
            password=password,
            first_name=full_name,
        )

        # Log in to create session
        login(request, user)

        session_key = request.session.session_key
        if not session_key:
            request.session.create()
            session_key = request.session.session_key

        return JsonResponse(
            {
                'session_id': session_key,
                'user': {
                    'full_name': full_name,
                    'email': email,
                },
            },
            status=status.HTTP_201_CREATED,
        )


class SignInView(APIView):
    """
    POST only. Authenticates with email and password; creates session and returns session_id and user info.
    Body: email, password.
    """
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        data = request.data if hasattr(request, 'data') and request.data is not None else {}
        if not isinstance(data, dict):
            data = {}

        email = (data.get('email') or '').strip().lower()
        password = data.get('password') or ''

        if not email:
            return JsonResponse(
                {'error': 'Email is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not password:
            return JsonResponse(
                {'error': 'Password is required.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        if not EMAIL_REGEX.match(email):
            return JsonResponse(
                {'error': 'Enter a valid email address.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        # User was created with username=email
        user = authenticate(request, username=email, password=password)
        if user is None:
            return JsonResponse(
                {'error': 'Invalid email or password.'},
                status=status.HTTP_401_UNAUTHORIZED,
            )

        login(request, user)
        session_key = request.session.session_key
        if not session_key:
            request.session.create()
            session_key = request.session.session_key

        full_name = user.get_full_name() or user.first_name or ''
        return JsonResponse(
            {
                'session_id': session_key,
                'user': {
                    'full_name': full_name,
                    'email': user.email,
                },
            },
            status=status.HTTP_200_OK,
        )


class LogoutView(APIView):
    """POST /api/auth/logout/ — invalidates the current session."""
    authentication_classes = []
    permission_classes = []

    def post(self, request):
        auth_logout(request)
        return JsonResponse({'message': 'Logged out successfully.'})


class ProfileView(APIView):
    """GET /api/auth/me/ — returns the authenticated user + Firestore profile."""

    def get(self, request):
        if not request.user or not request.user.is_authenticated:
            return JsonResponse({'error': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)
        user = request.user
        profile = get_tourist_profile(str(user.id))
        full_name = user.get_full_name() or user.first_name or ''
        return JsonResponse({
            'user': {
                'id': user.id,
                'full_name': full_name,
                'email': user.email,
            },
            'profile': profile,
        })


class OnboardingView(APIView):
    """POST /api/onboarding/ — saves tourist profile data to Firestore."""

    def post(self, request):
        if not request.user or not request.user.is_authenticated:
            return JsonResponse({'error': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)

        data = request.data if hasattr(request, 'data') and request.data else {}
        if not isinstance(data, dict):
            data = {}

        save_tourist_profile(str(request.user.id), dict(data))

        # Auto-issue blockchain credential — non-fatal if blockchain is unavailable
        try:
            _auto_issue_credential(request.user, dict(data))
        except Exception:
            pass

        return JsonResponse({'message': 'Profile saved successfully.'})


class SOSView(APIView):
    """POST /api/sos/ — creates an SOS incident in Firestore."""

    def post(self, request):
        if not request.user or not request.user.is_authenticated:
            return JsonResponse({'error': 'Authentication required.'}, status=status.HTTP_401_UNAUTHORIZED)

        data = request.data if hasattr(request, 'data') and request.data else {}
        tourist_name = str(data.get('tourist_name') or request.user.first_name or 'Unknown')
        tourist_nationality = str(data.get('nationality') or '')
        latitude = float(data.get('latitude') or 0.0)
        longitude = float(data.get('longitude') or 0.0)
        address = str(data.get('address') or '')

        incident_id = create_sos_incident(
            tourist_name=tourist_name,
            tourist_nationality=tourist_nationality,
            latitude=latitude,
            longitude=longitude,
            address=address,
            user_id=request.user.email,
        )

        return JsonResponse({'message': 'SOS alert triggered.', 'incident_id': incident_id})


# ── Blockchain Digital ID ────────────────────────────────────────────────────


def _auto_issue_credential(user, profile_data: dict):
    if TouristDigitalID.objects.filter(user=user, is_active=True).exists():
        return

    full_name = (
        f"{profile_data.get('first_name', '')} {profile_data.get('last_name', '')}".strip()
        or user.first_name or 'Unknown'
    )
    nationality     = profile_data.get('nationality', 'Unknown')
    passport_number = profile_data.get('passport_number', '')
    if not passport_number:
        return

    svc    = get_blockchain_service()
    result = svc.issue_credential(
        user_id         = str(user.id),
        full_name       = full_name,
        nationality     = nationality,
        passport_number = passport_number,
        entry_point     = 'app_onboarding',
    )

    issued_at_dt = datetime.fromisoformat(result['issued_at'])
    digital_id = TouristDigitalID.objects.create(
        user              = user,
        did               = result['did'],
        credential_id_hex = result['credential_id_hex'],
        data_hash_hex     = result['data_hash_hex'],
        tx_hash           = result['tx_hash'],
        issued_at         = issued_at_dt,
        entry_point       = 'app_onboarding',
    )

    db.collection('digital_ids').document(str(user.id)).set({
        'userId':          str(user.id),
        'did':             result['did'],
        'credentialIdHex': result['credential_id_hex'],
        'dataHashHex':     result['data_hash_hex'],
        'txHash':          result['tx_hash'],
        'issuedAt':        firestore.SERVER_TIMESTAMP,
        'entryPoint':      'app_onboarding',
        'isActive':        True,
    })

    return digital_id


class IssueCredentialView(APIView):
    """
    POST /api/digital-id/issue/
    Issues an on-chain credential for the authenticated tourist.
    Idempotent: returns existing credential if already issued.
    """

    def post(self, request):
        if not request.user or not request.user.is_authenticated:
            return JsonResponse({'error': 'Authentication required.'}, status=401)

        user = request.user

        try:
            existing = TouristDigitalID.objects.get(user=user, is_active=True)
            return JsonResponse({
                'did':               existing.did,
                'credential_id_hex': existing.credential_id_hex,
                'data_hash_hex':     existing.data_hash_hex,
                'tx_hash':           existing.tx_hash,
                'issued_at':         existing.issued_at.isoformat(),
                'entry_point':       existing.entry_point,
                'explorer_url':      existing.sepolia_explorer_url,
                'already_issued':    True,
            }, status=200)
        except TouristDigitalID.DoesNotExist:
            pass

        profile = get_tourist_profile(str(user.id))
        if not profile:
            return JsonResponse(
                {'error': 'Tourist profile not found. Complete onboarding first.'},
                status=400,
            )

        full_name = (
            f"{profile.get('first_name', '')} {profile.get('last_name', '')}".strip()
            or user.first_name or 'Unknown'
        )
        nationality     = profile.get('nationality', 'Unknown')
        passport_number = profile.get('passport_number', '')
        entry_point     = (request.data or {}).get('entry_point', 'app_onboarding')

        if not passport_number:
            return JsonResponse(
                {'error': 'Passport number is required to issue a credential.'},
                status=400,
            )

        try:
            svc    = get_blockchain_service()
            result = svc.issue_credential(
                user_id         = str(user.id),
                full_name       = full_name,
                nationality     = nationality,
                passport_number = passport_number,
                entry_point     = entry_point,
            )
        except EnvironmentError as e:
            return JsonResponse({'error': f'Blockchain not configured: {e}'}, status=503)
        except Exception as e:
            return JsonResponse({'error': f'Blockchain error: {e}'}, status=500)

        issued_at_dt = datetime.fromisoformat(result['issued_at'])
        digital_id = TouristDigitalID.objects.create(
            user              = user,
            did               = result['did'],
            credential_id_hex = result['credential_id_hex'],
            data_hash_hex     = result['data_hash_hex'],
            tx_hash           = result['tx_hash'],
            issued_at         = issued_at_dt,
            entry_point       = entry_point,
        )

        db.collection('digital_ids').document(str(user.id)).set({
            'userId':          str(user.id),
            'did':             result['did'],
            'credentialIdHex': result['credential_id_hex'],
            'dataHashHex':     result['data_hash_hex'],
            'txHash':          result['tx_hash'],
            'issuedAt':        firestore.SERVER_TIMESTAMP,
            'entryPoint':      entry_point,
            'isActive':        True,
        })

        return JsonResponse({
            'did':               digital_id.did,
            'credential_id_hex': digital_id.credential_id_hex,
            'data_hash_hex':     digital_id.data_hash_hex,
            'tx_hash':           digital_id.tx_hash,
            'issued_at':         digital_id.issued_at.isoformat(),
            'entry_point':       digital_id.entry_point,
            'explorer_url':      digital_id.sepolia_explorer_url,
            'already_issued':    False,
        }, status=201)


class GetCredentialView(APIView):
    """GET /api/digital-id/me/ — returns the authenticated tourist's digital ID."""

    def get(self, request):
        if not request.user or not request.user.is_authenticated:
            return JsonResponse({'error': 'Authentication required.'}, status=401)

        try:
            did_obj = TouristDigitalID.objects.get(user=request.user, is_active=True)
        except TouristDigitalID.DoesNotExist:
            return JsonResponse({'error': 'No digital ID found.'}, status=404)

        return JsonResponse({
            'did':               did_obj.did,
            'credential_id_hex': did_obj.credential_id_hex,
            'data_hash_hex':     did_obj.data_hash_hex,
            'tx_hash':           did_obj.tx_hash,
            'issued_at':         did_obj.issued_at.isoformat(),
            'entry_point':       did_obj.entry_point,
            'explorer_url':      did_obj.sepolia_explorer_url,
        })


class VerifyCredentialView(APIView):
    """
    GET /api/digital-id/verify/<credential_id_hex>/
    Public — no auth required. Police/check-points can verify by scanning the QR.
    Degrades gracefully if Sepolia RPC is unavailable.
    """
    authentication_classes = []
    permission_classes = []

    def get(self, request, credential_id_hex: str):
        try:
            did_obj = TouristDigitalID.objects.get(
                credential_id_hex=credential_id_hex
            )
        except TouristDigitalID.DoesNotExist:
            return JsonResponse({'error': 'Credential not found in registry.'}, status=404)

        try:
            svc    = get_blockchain_service()
            result = svc.verify_credential(credential_id_hex)
        except Exception as e:
            return JsonResponse({
                'did':            did_obj.did,
                'issued_at':      did_obj.issued_at.isoformat(),
                'entry_point':    did_obj.entry_point,
                'is_valid':       did_obj.is_active,
                'chain_verified': False,
                'chain_error':    str(e),
                'explorer_url':   did_obj.sepolia_explorer_url,
            })

        hashes_match = (result['data_hash_hex'] == did_obj.data_hash_hex)

        return JsonResponse({
            'did':            did_obj.did,
            'issued_at':      did_obj.issued_at.isoformat(),
            'entry_point':    did_obj.entry_point,
            'is_valid':       result['is_valid'] and did_obj.is_active and hashes_match,
            'chain_verified': True,
            'hashes_match':   hashes_match,
            'issued_by':      result['issued_by'],
            'explorer_url':   did_obj.sepolia_explorer_url,
        })
