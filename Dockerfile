FROM rustlang/rust:nightly-buster AS build

RUN apt-get update
RUN apt-get install -y musl-tools

RUN rustup --version
RUN rustup target add x86_64-unknown-linux-musl

RUN rustc --version && \
    rustup --version && \
    cargo --version

WORKDIR /app
COPY . /app
RUN cargo clean && cargo build --release --target x86_64-unknown-linux-musl
RUN strip ./target/x86_64-unknown-linux-musl/release/overseer

FROM scratch

WORKDIR /usr/src/overseer

COPY ./res/assets/ ./res/assets/
COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /app/target/x86_64-unknown-linux-musl/release/overseer /usr/local/bin/overseer

CMD [ "overseer", "-c", "/etc/overseer.cfg" ]

EXPOSE 8080
