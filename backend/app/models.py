from sqlalchemy import Column, Integer, String, Float, Boolean, Text, BigInteger, DateTime
from sqlalchemy.sql import func
from app.database import Base


class ChatConversation(Base):
    __tablename__ = "chat_conversations"
    id = Column(Integer, primary_key=True, autoincrement=True)
    titulo = Column(String(200), default="")
    modelo = Column(String(100), default="")
    mensajes = Column(Text, default="")  # JSON string
    creado_en = Column(BigInteger)
    actualizado_en = Column(BigInteger)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, autoincrement=True)
    username = Column(String(100), unique=True, nullable=False, index=True)
    password_hash = Column(String(200), nullable=False)
    email = Column(String(200), unique=True, nullable=True, index=True)
    nombre_completo = Column(String(200), nullable=True)
    rol = Column(String(50), default="enfermero")  # enfermero, admin, estudiante
    activo = Column(Boolean, default=True)
    creado_en = Column(DateTime, server_default=func.now())
    ultimo_acceso = Column(DateTime, nullable=True)

class TimerTurno(Base):
    __tablename__ = "timers"

    id = Column(Integer, primary_key=True, autoincrement=True)
    turno_id = Column(String, nullable=True)
    centro = Column(String, default="")
    entrada = Column(BigInteger)
    salida = Column(BigInteger, nullable=True)
    tarifa = Column(Float, default=0.0)
    activo = Column(Boolean, default=True)

class NotaTraspaso(Base):
    __tablename__ = "notas_traspaso"

    id = Column(Integer, primary_key=True, autoincrement=True)
    paciente = Column(String, nullable=False)
    diagnostico = Column(String, default="")
    resumen = Column(Text, default="")
    signos_vitales = Column(String, default="")
    actualizado = Column(BigInteger)
    completada = Column(Boolean, default=False)
    prioridad = Column(String, default="baja")  # alta, media, baja

class PlanPAE(Base):
    __tablename__ = "planes_pae"

    id = Column(Integer, primary_key=True, autoincrement=True)
    paciente = Column(String, nullable=False)
    valoracion = Column(Text, default="")
    diagnostico_nanda = Column(String, default="")
    objetivos_noc = Column(String, default="")
    intervenciones_nic = Column(Text, default="")
    evaluacion = Column(Text, default="")
    timestamp = Column(BigInteger)


class DrugReference(Base):
    __tablename__ = "drug_references"

    id = Column(Integer, primary_key=True, autoincrement=True)
    nombre_generico = Column(String(200), nullable=False, unique=True)
    categoria = Column(String(200), default="")
    indicacion = Column(Text, default="")
    dosis_adulto = Column(String(300), default="")
    dosis_pediatrica = Column(String(300), default="")
    via = Column(String(200), default="")
    precauciones = Column(Text, default="")
    alerta = Column(Text, default="")
    presentacion = Column(Text, default="")
    contraindicaciones = Column(Text, default="")
    interacciones = Column(Text, default="")
    efectos_adversos = Column(Text, default="")
    embarazo_lactancia = Column(Text, default="")
    mecanismo_accion = Column(Text, default="")
