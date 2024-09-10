#!/bin/bash
IS_TRAINING=1 uvicorn app:app --host 0.0.0.0 --port $PORT --proxy-headers --forwarded-allow-ips="*"