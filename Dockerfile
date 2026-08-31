# Build stage
FROM python:alpine@sha256:05b2b8b732ecd268fee8727a369f936f022d1321b59befd13c30ede22769dcdc AS builder
COPY requirements.txt /
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install --disable-pip-version-check --root-user-action ignore -r requirements.txt --target /packages

# Runtime stage
FROM gcr.io/distroless/python3:nonroot@sha256:f3d5ddc6c64a019fe520e7f005f2880be21e6afc461b10a3c15ef2e4edc71e33
COPY --from=builder /packages /packages
WORKDIR /app
COPY . /app
ENV PYTHONPATH=/packages

EXPOSE 3000

CMD ["-m", "gunicorn", "--bind", " 0.0.0.0:3000", "app:app"]
