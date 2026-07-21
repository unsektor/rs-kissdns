FROM rust:alpine AS kissdns-builder-alpine

WORKDIR /app
COPY Cargo.toml Cargo.lock ./

# Empty source to cache dependencies
RUN set -aeux ; mkdir src && \
    echo "fn main() {}" > src/main.rs && \
    cargo build && \
    rm -rf src

COPY src ./src
RUN cargo build

# FROM alpine:latest AS kissdns-alpine
FROM rust:alpine AS kissdns-alpine

COPY --from=kissdns-builder-alpine /app/target/debug/kissdns /usr/local/bin/
RUN adduser -D -u 1000 kissdns && \
    chown kissdns:kissdns /usr/local/bin/kissdns

USER kissdns
WORKDIR /home/kissdns

ENTRYPOINT ["/usr/local/bin/kissdns"]
