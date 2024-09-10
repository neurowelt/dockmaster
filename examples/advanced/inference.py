from fastapi import APIRouter
from fastapi.responses import JSONResponse

from utils import hash_func


router = APIRouter()

@router.get('/inference')
async def inference() -> JSONResponse:
    # Perform inference here
    return JSONResponse(
        content={'status': 'ok', 'result': hash_func('inference')}
    )
