import logging
import os
from pathlib import Path

from dotenv import load_dotenv
from fastapi import FastAPI, HTTPException
from fastapi.concurrency import run_in_threadpool
from google import genai
from pydantic import BaseModel, Field

load_dotenv(Path(__file__).with_name('.env'))

logging.basicConfig(level=os.getenv('LOG_LEVEL', 'INFO'))
logger = logging.getLogger('maisuchat.ai')

API_KEY = os.getenv('GEMINI_API_KEY')
MODEL_NAME = os.getenv('GEMINI_MODEL', 'gemini-2.5-flash-lite')
client = genai.Client(api_key=API_KEY) if API_KEY else None

app = FastAPI(
    title='MaisuChat AI Service',
    version='0.2.0',
    description='Serviço de respostas assistidas para o MaisuChat.',
)


class Message(BaseModel):
    text: str = Field(min_length=1, max_length=4_000)
    user_id: str | None = Field(default=None, max_length=128)


@app.get('/health')
async def health() -> dict[str, str]:
    return {
        'status': 'ok',
        'service': 'maisuchat-ai',
        'gemini': 'configured' if client else 'not-configured',
        'model': MODEL_NAME,
    }


@app.post('/generate')
async def generate(msg: Message) -> dict[str, str]:
    if client is None:
        raise HTTPException(
            status_code=503,
            detail='GEMINI_API_KEY não configurada neste ambiente.',
        )

    prompt = msg.text.strip()
    if not prompt:
        raise HTTPException(status_code=422, detail='text não pode ficar vazio.')

    try:
        response = await run_in_threadpool(
            client.models.generate_content,
            model=MODEL_NAME,
            contents=prompt,
        )
    except Exception as error:
        logger.exception('Gemini request failed: %s', error)
        raise HTTPException(
            status_code=502,
            detail='O provedor de IA não respondeu. Tente novamente.',
        ) from error

    reply = (getattr(response, 'text', None) or '').strip()
    if not reply:
        raise HTTPException(
            status_code=502,
            detail='O provedor de IA retornou uma resposta vazia.',
        )

    return {'reply': reply, 'model': MODEL_NAME}
