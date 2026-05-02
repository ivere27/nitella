# Nitella universal build image.
#
# This image is intentionally larger than runtime images. It contains the
# shared Go/Rust/protobuf/SQLite toolchain used by the project Dockerfiles.

FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.6.1 AS xx

FROM golang:1.24-alpine

COPY --from=xx / /

RUN apk add --no-cache \
    build-base \
    ca-certificates \
    cargo \
    clang \
    curl \
    git \
    lld \
    pkgconf \
    protobuf \
    protobuf-dev \
    rust \
    sqlite-dev

ENV CC=clang \
    CXX=clang++ \
    PROTOC_INCLUDE=/usr/include

WORKDIR /app
