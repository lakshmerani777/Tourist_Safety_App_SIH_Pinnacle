from pathlib import Path

from decouple import Config, RepositoryEnv

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve().parent.parent

# Load .env from project root (PinnacleBackend directory)
_env_file = BASE_DIR / '.env'
_config = Config(RepositoryEnv(str(_env_file))) if _env_file.exists() else None


def _get(key, default=None, cast=None):
    if _config is None:
        return default
    if cast is None:
        return _config(key, default=default)
    return _config(key, default=default, cast=cast)


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/6.0/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = _get('SECRET_KEY', 'django-insecure-m4=8@z-0!vv4leea(2hu))@e*m!6+!8b-h9w-6mzh*8vcoe3sa')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = _get('DEBUG', True, cast=lambda v: str(v).lower() in ('1', 'true', 'yes'))

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '10.0.2.2',
    'pleuropneumonic-mai-soapily.ngrok-free.dev',
    '.ngrok-free.dev',  # any ngrok tunnel subdomain
]


# Application definition

INSTALLED_APPS = [
    'corsheaders',
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'backend',
    'dashboard',
    'rest_framework',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
]

ROOT_URLCONF = 'PinnacleBackend.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [BASE_DIR / 'dashboard' / 'templates'],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'PinnacleBackend.wsgi.application'


# Database
# https://docs.djangoproject.com/en/6.0/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}


# Password validation
# https://docs.djangoproject.com/en/6.0/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]


# Internationalization
# https://docs.djangoproject.com/en/6.0/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'UTC'

USE_I18N = True

USE_TZ = True


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/6.0/howto/static-files/

STATIC_URL = 'static/'

# CORS: allow Flutter app (dev)
CORS_ALLOW_ALL_ORIGINS = True  # Restrict in production (e.g. CORS_ALLOWED_ORIGINS)

# REST framework: session key from X-Session-Id for API auth
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': [
        'backend.authentication.SessionKeyAuthentication',
        'rest_framework.authentication.SessionAuthentication',
    ],
}

# Google Maps API key (from .env); used by config endpoint for the app
GOOGLE_MAPS_API_KEY = _get('GOOGLE_MAPS_API_KEY', '')
