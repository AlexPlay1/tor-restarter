# Build stage
FROM python:alpine@sha256:2e740b2c28a426e74f11396c05e38afb3191acced75045b8d62df573c1dc8ce8 AS builder
COPY requirements.txt /
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install --disable-pip-version-check --root-user-action ignore -r requirements.txt --target /packages

# Runtime stage
FROM gcr.io/distroless/python3:nonroot@sha256:8ee214843129f43e2ebf5e0ca9f2e4e6d8292143d1b8a6787f169b5898578884
COPY --from=builder /packages /packages
WORKDIR /app
COPY . /app
ENV PYTHONPATH=/packages

EXPOSE 3000

CMD ["-m", "gunicorn", "--bind", " 0.0.0.0:3000", "app:app"]
