# Build stage
FROM python:alpine@sha256:05b2b8b732ecd268fee8727a369f936f022d1321b59befd13c30ede22769dcdc AS builder
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
