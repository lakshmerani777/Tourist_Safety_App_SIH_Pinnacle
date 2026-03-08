import re
from django.contrib.auth import authenticate, get_user_model, login
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError
from django.http import JsonResponse
from rest_framework import status
from rest_framework.views import APIView

User = get_user_model()

EMAIL_REGEX = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')


class HelloView(APIView):
    def get(self, request):
        return JsonResponse({'message': 'Hello, world!'})


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
