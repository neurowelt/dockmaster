# source: https://github.com/tiangolo/uvicorn-gunicorn-docker/blob/master/docker-images/python3.8-slim.dockerfile
FROM python:3.10-slim

COPY . .

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

ARG API_KEY
ENV API_KEY=$API_KEY

ENTRYPOINT [ "python3" ]