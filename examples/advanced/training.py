import hashlib

from fastapi import APIRouter
from fastapi.responses import JSONResponse


router = APIRouter()

@router.get('/training')
async def training() -> JSONResponse:
    # Perform training here
    return JSONResponse(
        content={'status': 'ok', 'result': hashlib.sha256(b"training").hexdigest()}
    )
