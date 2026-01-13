# FROM rust:1.92.0-slim AS builder

# WORKDIR /app

# COPY . .

# RUN apt update && apt upgrade -y

# RUN apt install -y protobuf-compiler libprotobuf-dev build-essential

# RUN rustup default nightly && cargo build --release --bin stat_server

# FROM gcr.io/distroless/cc-debian12

# COPY --from=builder /app/config.toml /usr/local/etc/stat_server/config.toml
# COPY --from=builder /app/target/release/stat_server /usr/local/bin/stat_server

# RUN apt update -y && apt install -y build-essential

# WORKDIR /
# EXPOSE 8080 9394

# ENV RUST_LOG=info

# ENTRYPOINT ["/usr/local/bin/stat_server"]
# CMD ["-c", "/usr/local/etc/stat_server/config.toml"]
FROM rust:1.92.0-alpine3.23 AS builder

WORKDIR /app
COPY ./ /app

RUN apk add --no-cache musl-dev git cmake make g++
RUN rustup default nightly && cargo build --release --bin stat_server
RUN strip /app/target/release/stat_server

FROM scratch AS production

COPY --from=builder /app/config.toml /etc/stat_server/config.toml
COPY --from=builder /app/target/release/stat_server /stat_server

WORKDIR /
EXPOSE 8080 9394

CMD ["/stat_server", "-c", "/etc/stat_server/config.toml"]
