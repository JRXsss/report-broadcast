import json
import requests

def send_wecom_text(webhook_url: str, text: str):
    payload = {"msgtype": "text", "text": {"content": text}}
    r = requests.post(webhook_url, data=json.dumps(payload), headers={"Content-Type":"application/json"}, timeout=30)
    r.raise_for_status()
    data = r.json()
    if data.get("errcode") != 0:
        raise RuntimeError(f"WECOM webhook error: {data}")
