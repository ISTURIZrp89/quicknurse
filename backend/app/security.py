from datetime import datetime, timedelta, timezone
import logging
from jose import JWTError, jwt
from passlib.context import CryptContext
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
from pydantic import BaseModel
from app.config import get_settings
import pyotp

settings = get_settings()

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

# Token configs
ACCESS_TOKEN_EXPIRE_MINUTES = 15
REFRESH_TOKEN_EXPIRE_DAYS = 30


def create_access_token(data: dict, expires_delta: timedelta | None = None) -> str:
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.now(timezone.utc) + expires_delta
    else:
        expire = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire, "type": "access"})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_refresh_token(data: dict) -> str:
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(days=REFRESH_TOKEN_EXPIRE_DAYS)
    to_encode.update({"exp": expire, "type": "refresh", "jti": jwt.encode({"sub": data.get("sub")}, settings.SECRET_KEY, algorithm=settings.ALGORITHM)[:8]})
    return jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)


def create_token_pair(user_id: int, username: str, role: str) -> dict:
    """Crear access + refresh token pair."""
    access = create_access_token({"sub": username, "user_id": user_id, "role": role})
    refresh = create_refresh_token({"sub": username, "user_id": user_id})
    return {
        "access_token": access,
        "refresh_token": refresh,
        "token_type": "bearer",
        "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60,
    }


def verify_password(plain_password: str, hashed_password: str) -> bool:
    return pwd_context.verify(plain_password, hashed_password)


def get_password_hash(password: str) -> str:
    return pwd_context.hash(password)


# 2FA Functions
def generate_totp_secret() -> str:
    return pyotp.random_base32()


def get_totp_uri(secret: str, email: str, issuer: str = "QuickNurse") -> str:
    return pyotp.totp.TOTP(secret).provisioning_uri(name=email, issuer_name=issuer)


def verify_totp(secret: str, token: str, valid_window: int = 1) -> bool:
    totp = pyotp.TOTP(secret)
    return totp.verify(token, valid_window=valid_window)


def generate_backup_codes(count: int = 10) -> list[str]:
    import secrets
    return [secrets.token_hex(4).upper() for _ in range(count)]


def hash_backup_codes(codes: list[str]) -> list[str]:
    return [get_password_hash(code) for code in codes]


def verify_backup_code(hashed_codes: list[str], code: str) -> bool:
    for hashed in hashed_codes:
        if verify_password(code, hashed):
            return True
    return False


async def get_current_user(token: str = Depends(oauth2_scheme)):
    from app.database import get_async_db
    from sqlalchemy.ext.asyncio import AsyncSession
    from sqlalchemy import select
    from app.models import User, UserRole

    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Credenciales inválidas",
        headers={"WWW-Authenticate": "Bearer"},
    )
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        username: str = payload.get("sub")
        if username is None:
            raise credentials_exception
        if payload.get("type") != "access":
            raise credentials_exception
    except JWTError:
        raise credentials_exception

    # Note: async db session would need to be injected
    # For now, return username; actual user object loaded in endpoints
    return username


class Token(BaseModel):
    access_token: str
    refresh_token: str | None = None
    token_type: str
    expires_in: int | None = None


class TokenData(BaseModel):
    username: str | None = None


class RefreshRequest(BaseModel):
    refresh_token: str


class TwoFASetupResponse(BaseModel):
    secret: str
    uri: str
    backup_codes: list[str]


class TwoFAVerifyRequest(BaseModel):
    code: str


class TwoFADisableRequest(BaseModel):
    code: str