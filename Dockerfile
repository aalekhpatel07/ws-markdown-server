FROM rust:1.66 AS builder
WORKDIR /app
COPY . .
# COPY Cargo.toml Cargo.toml
# COPY Cargo.lock Cargo.lock
# COPY src/ src/

RUN cargo install --path .

FROM debian:buster-slim
RUN apt-get update -y
RUN apt-get install -y libssl-dev
COPY --from=builder /usr/local/cargo/bin/ws-markdown-server /usr/local/bin/ws-markdown-server

ENV RUST_LOG="ws_markdown_server=debug"
ENV MD_SERVER_WS_PORT="9003"
ENV MD_SERVER_TCP_PORT="9004"
ENV MD_SERVER_HOST="0.0.0.0"
ENV MD_HEALTHCHECK_PORT="9005"

ENTRYPOINT ["ws-markdown-server"]
