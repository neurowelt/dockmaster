import hashlib

from fastapi import APIRouter
from fastapi.responses import JSONResponse


router = APIRouter()

@router.get('/inference')
async def inference() -> JSONResponse:
    # Perform inference here
    return JSONResponse(
        content={'status': 'ok', 'result': hashlib.sha256(b"inference").hexdigest()}
    )
