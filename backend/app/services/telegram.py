import urllib.request
import urllib.parse
import json
import os

TELEGRAM_TOKEN = "878786:CEyA"  # In real deployments read from environment variables or settings
TELEGRAM_CHAT_ID = "1039685725"

def send_telegram_message(message: str) -> bool:
    """Envía un mensaje al canal o chat de Telegram configurado."""
    try:
        url = f"https://api.telegram.org/bot{TELEGRAM_TOKEN}/sendMessage"
        data = urllib.parse.urlencode({
            "chat_id": TELEGRAM_CHAT_ID,
            "text": message,
            "parse_mode": "Markdown"
        }).encode("utf-8")
        
        req = urllib.request.Request(url, data=data)
        with urllib.request.urlopen(req, timeout=10) as response:
            res = json.loads(response.read().decode())
            return res.get("ok", False)
    except Exception as e:
        print(f"Error enviando mensaje por Telegram: {e}")
        return False
