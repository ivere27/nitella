# Nitella universal build image.
#
# This image is intentionally larger than runtime images. It contains the
# shared Go/Rust/protobuf/SQLite toolchain used by the project Dockerfiles.

FROM golang:1.24-alpine

RUN apk add --no-cache \
    build-base \
    ca-certificates \
    cargo \
    curl \
    git \
    pkgconf \
    protobuf \
    protobuf-dev \
    rust \
    sqlite-dev

ENV PROTOC_INCLUDE=/usr/include

WORKDIR /app
