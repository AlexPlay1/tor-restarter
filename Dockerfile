# Build stage
FROM python:alpine@sha256:f6a589d43c42b9e7f7dc67a12d37132491f362859a5d750607710cc56da3bc72 AS builder
COPY requirements.txt /
RUN --mount=type=cache,target=/root/.cache/pip \
  pip install --disable-pip-version-check --root-user-action ignore -r requirements.txt --target /packages

# Runtime stage
FROM gcr.io/distroless/python3:nonroot@sha256:774595d652a294b54c9bd575b2d9fdd1a4b47547dc17b8bfa4c0e953c64855b3
COPY --from=builder /packages /packages
WORKDIR /app
COPY . /app
ENV PYTHONPATH=/packages

EXPOSE 3000

CMD ["-m", "gunicorn", "--bind", " 0.0.0.0:3000", "app:app"]
