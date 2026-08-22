# Build stage
FROM python:alpine@sha256:05b2b8b732ecd268fee8727a369f936f022d1321b59befd13c30ede22769dcdc AS builder
COPY requirements.txt /
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install --disable-pip-version-check --root-user-action ignore -r requirements.txt --target /packages

# Runtime stage
FROM gcr.io/distroless/python3:nonroot@sha256:6bfc400d0a6d89f50f5bbc0a4b4ff57214ae5c01647c3a74c2a0c8d830b4cc00
COPY --from=builder /packages /packages
WORKDIR /app
COPY . /app
ENV PYTHONPATH=/packages

EXPOSE 3000

CMD ["-m", "gunicorn", "--bind", " 0.0.0.0:3000", "app:app"]
