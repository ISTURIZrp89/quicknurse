from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, EmailStr
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.database import get_async_db
from app.models import User, UserRole
from app.security import (
    verify_password,
    get_password_hash,
    create_token_pair,
    get_current_user,
    generate_totp_secret,
    get_totp_uri,
    verify_totp,
    generate_backup_codes,
    hash_backup_codes,
    verify_backup_code,
    create_access_token,
    create_refresh_token,
    RefreshRequest,
    TwoFASetupResponse,
    TwoFAVerifyRequest,
    TwoFADisableRequest,
    Token,
)
from jose import jwt
from app.config import get_settings

settings = get_settings()

router = APIRouter(prefix="/auth", tags=["auth"])


class UserCreate(BaseModel):
    username: str
    password: str
    email: EmailStr | None = None
    nombre_completo: str | None = None
    rol: UserRole = UserRole.CLINICIAN


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    email: str | None
    nombre_completo: str | None
    rol: UserRole
    activo: bool
    totp_enabled: bool

    class Config:
        from_attributes = True


class RefreshResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    expires_in: int


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_async_db)):
    # Verificar username único
    stmt = select(User).where(User.username == user_data.username)
    existing = (await db.execute(stmt)).scalar_one_or_none()
    if existing:
        raise HTTPException(status_code=400, detail="Usuario ya existe")

    # Verificar email único si se proporciona
    if user_data.email:
        stmt = select(User).where(User.email == user_data.email)
        existing = (await db.execute(stmt)).scalar_one_or_none()
        if existing:
            raise HTTPException(status_code=400, detail="Email ya registrado")

    user = User(
        username=user_data.username,
        password_hash=get_password_hash(user_data.password),
        email=user_data.email,
        nombre_completo=user_data.nombre_completo,
        rol=user_data.rol,
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


@router.post("/login", response_model=Token)
async def login(login_data: UserLogin, db: AsyncSession = Depends(get_async_db)):
    stmt = select(User).where(User.username == login_data.username)
    user = (await db.execute(stmt)).scalar_one_or_none()

    if not user or not verify_password(login_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    if not user.activo:
        raise HTTPException(status_code=403, detail="Usuario inactivo")

    # Si tiene 2FA habilitado, requerir código
    if user.totp_enabled:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="2FA_REQUIRED",
            headers={"X-2FA-Required": "true"},
        )

    # Actualizar último acceso
    user.ultimo_acceso = datetime.now(timezone.utc)
    await db.commit()

    tokens = create_token_pair(user.id, user.username, user.rol.value)
    return tokens


@router.post("/login/2fa", response_model=Token)
async def login_2fa(username: str, code: str, db: AsyncSession = Depends(get_async_db)):
    """Login con 2FA después de login inicial."""
    stmt = select(User).where(User.username == username)
    user = (await db.execute(stmt)).scalar_one_or_none()

    if not user or not user.totp_enabled:
        raise HTTPException(status_code=401, detail="Credenciales inválidas")

    if not verify_totp(user.totp_secret, code):
        # Intentar backup codes
        if not verify_backup_code(user.backup_codes, code):
            raise HTTPException(status_code=401, detail="Código 2FA inválido")

        # Si usó backup code, invalidar ese código
        new_codes = [c for c in user.backup_codes if not verify_password(code, c)]
        user.backup_codes = new_codes

    user.ultimo_acceso = datetime.now(timezone.utc)
    await db.commit()

    return create_token_pair(user.id, user.username, user.rol.value)


@router.post("/refresh", response_model=RefreshResponse)
async def refresh_token(request: RefreshRequest):
    """Renovar access token usando refresh token."""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Refresh token inválido o expirado",
    )
    try:
        payload = jwt.decode(request.refresh_token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        if payload.get("type") != "refresh":
            raise credentials_exception
        username: str = payload.get("sub")
        user_id: int = payload.get("user_id")
        role: str = payload.get("role", "clinician")
        if username is None:
            raise credentials_exception
    except jwt.JWTError:
        raise credentials_exception

    access = create_access_token({"sub": username, "user_id": user_id, "role": role})
    return {"access_token": access, "token_type": "bearer", "expires_in": ACCESS_TOKEN_EXPIRE_MINUTES * 60}


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: str = Depends(get_current_user), db: AsyncSession = Depends(get_async_db)):
    stmt = select(User).where(User.username == current_user)
    user = (await db.execute(stmt)).scalar_one_or_none()
    if not user:
        raise HTTPException(404, "Usuario no encontrado")
    return user


# ========== 2FA ENDPOINTS ==========

@router.post("/2fa/setup", response_model=TwoFASetupResponse)
async def setup_2fa(current_user: str = Depends(get_current_user), db: AsyncSession = Depends(get_async_db)):
    """Configurar 2FA - genera secret y backup codes."""
    stmt = select(User).where(User.username == current_user)
    user = (await db.execute(stmt)).scalar_one_or_none()
    if not user:
        raise HTTPException(404, "Usuario no encontrado")

    if user.totp_enabled:
        raise HTTPException(400, "2FA ya está habilitado")

    secret = generate_totp_secret()
    uri = get_totp_uri(secret, user.email or user.username)
    backup_codes = generate_backup_codes(10)

    # Guardar temporalmente (sin habilitar hasta verificar)
    user.totp_secret = secret
    user.backup_codes = hash_backup_codes(backup_codes)
    await db.commit()

    return TwoFASetupResponse(secret=secret, uri=uri, backup_codes=backup_codes)


@router.post("/2fa/verify", response_model=Token)
async def verify_2fa(request: TwoFAVerifyRequest, current_user: str = Depends(get_current_user), db: AsyncSession = Depends(get_async_db)):
    """Verificar código 2FA para habilitarlo."""
    stmt = select(User).where(User.username == current_user)
    user = (await db.execute(stmt)).scalar_one_or_none()
    if not user:
        raise HTTPException(404, "Usuario no encontrado")

    if not user.totp_secret:
        raise HTTPException(400, "2FA no configurado")

    if not verify_totp(user.totp_secret, request.code):
        raise HTTPException(400, "Código 2FA inválido")

    # Habilitar 2FA
    user.totp_enabled = True
    await db.commit()

    return create_token_pair(user.id, user.username, user.rol.value)


@router.post("/2fa/disable")
async def disable_2fa(request: TwoFADisableRequest, current_user: str = Depends(get_current_user), db: AsyncSession = Depends(get_async_db)):
    """Deshabilitar 2FA - requiere código actual."""
    stmt = select(User).where(User.username == current_user)
    user = (await db.execute(stmt)).scalar_one_or_none()
    if not user or not user.totp_enabled:
        raise HTTPException(400, "2FA no está habilitado")

    if not verify_totp(user.totp_secret, request.code):
        if not verify_backup_code(user.backup_codes, request.code):
            raise HTTPException(400, "Código inválido")

    user.totp_enabled = False
    user.totp_secret = None
    user.backup_codes = []
    await db.commit()

    return {"message": "2FA deshabilitado correctamente"}


@router.get("/2fa/status")
async def get_2fa_status(current_user: str = Depends(get_current_user), db: AsyncSession = Depends(get_async_db)):
    stmt = select(User).where(User.username == current_user)
    user = (await db.execute(stmt)).scalar_one_or_none()
    if not user:
        raise HTTPException(404, "Usuario no encontrado")

    return {
        "enabled": user.totp_enabled,
        "backup_codes_count": len(user.backup_codes) if user.backup_codes else 0,
    }


# Importar al final para evitar circular imports
from datetime import datetime, timezone
from app.config import get_settings
from app.security import (
    verify_password,
    create_token_pair,
    create_access_token,
    create_refresh_token,
    verify_totp,
    verify_backup_code,
    ACCESS_TOKEN_EXPIRE_MINUTES,
)