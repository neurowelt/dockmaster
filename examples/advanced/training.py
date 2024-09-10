from fastapi import APIRouter
from fastapi.responses import JSONResponse

from utils import hash_func


router = APIRouter()

@router.get('/training')
async def training() -> JSONResponse:
    # Perform training here
    return JSONResponse(
        content={'status': 'ok', 'result': hash_func('training')}
    )
