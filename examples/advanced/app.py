import os

from .build import create_app

TRAINING = os.environ.get('IS_TRAINING', 0) == 1


app = create_app()