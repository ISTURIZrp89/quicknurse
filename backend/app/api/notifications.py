from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from app.services.telegram import send_telegram_message

router = APIRouter()

class NotifyRequest(BaseModel):
    message: str

@router.post("/")
def send_notification(request: NotifyRequest):
    success = send_telegram_message(request.message)
    if not success:
        raise HTTPException(status_code=500, detail="Error al enviar mensaje por Telegram.")
    return {"status": "sent", "message": request.message}
