#!/bin/bash
IS_TRAINING=0 uvicorn app:app --host 0.0.0.0 --port $PORT --proxy-headers --forwarded-allow-ips="*"