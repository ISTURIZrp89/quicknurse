from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel
from app.security import (
    verify_password,
    get_password_hash,
    create_access_token,
    get_current_user,
    Token,
)
from app.database import SessionLocal, get_db
from app.models import User
from sqlalchemy.orm import Session


router = APIRouter(prefix="/auth", tags=["auth"])


class UserCreate(BaseModel):
    username: str
    password: str
    email: str | None = None
    nombre_completo: str | None = None
    rol: str = "enfermero"


class UserLogin(BaseModel):
    username: str
    password: str


class UserResponse(BaseModel):
    id: int
    username: str
    email: str | None
    nombre_completo: str | None
    rol: str
    activo: bool

    class Config:
        from_attributes = True


@router.post("/register", response_model=UserResponse, status_code=status.HTTP_201_CREATED)
def register(user_data: UserCreate, db: Session = Depends(get_db)):
    existing = db.query(User).filter(User.username == user_data.username).first()
    if existing:
        raise HTTPException(status_code=400, detail="Usuario ya existe")

    user = User(
        username=user_data.username,
        password_hash=get_password_hash(user_data.password),
        email=user_data.email,
        nombre_completo=user_data.nombre_completo,
        rol=user_data.rol,
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


@router.post("/login", response_model=Token)
def login(login_data: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == login_data.username).first()
    if not user or not verify_password(login_data.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Credenciales inválidas")
    if not user.activo:
        raise HTTPException(status_code=403, detail="Usuario inactivo")

    access_token = create_access_token(data={"sub": user.username})
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=UserResponse)
def get_me(current_user: str = Depends(get_current_user), db: Session = Depends(get_db)):
    user = db.query(User).filter(User.username == current_user).first()
    if not user:
        raise HTTPException(status_code=404, detail="Usuario no encontrado")
    return user