import os

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .inference import router as inference_router
from .training import router as training_router


def create_app(is_training: bool) -> FastAPI:
    """
    Create FastAPI application.

    Args:
        is_training (bool): Whether app should be deployed with training
            or inference endpoints.

    Returns:
        FastAPI: FastAPI application.
    """
    app = FastAPI(title="My App", version="1.0.0")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=[
            "http://localhost:5000",
        ],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"]
    )

    if is_training:
        app.include_router(training_router)
    else:
        app.include_router(inference_router)

    return app
