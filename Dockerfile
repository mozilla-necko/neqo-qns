FROM ubuntu:19.04

RUN apt-get update && \
  apt-get install -y wget net-tools iputils-ping tcpdump ethtool iperf

# START stuff from mt
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates coreutils curl git make mercurial ssh \
    build-essential clang llvm libclang-dev gyp ninja-build pkg-config zlib1g-dev libnspr4-dev \
 && apt-get autoremove -y && apt-get clean -y \
 && rm -rf /var/lib/apt/lists/*

ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.41.1

RUN set -eux; \
    curl -sSLf "https://static.rust-lang.org/rustup/archive/1.20.2/x86_64-unknown-linux-gnu/rustup-init" -o rustup-init; \
    echo 'e68f193542c68ce83c449809d2cad262cc2bbb99640eb47c58fc1dc58cc30add *rustup-init' | sha256sum -c -; \
    chmod +x rustup-init; \
    ./rustup-init -y -q --no-modify-path --profile minimal --component rustfmt --component clippy --default-toolchain "$RUST_VERSION"; \
    rm -f rustup-init; \
    chmod -R a+w "$RUSTUP_HOME" "$CARGO_HOME"

ENV NSS_DIR=$HOME/nss \
    NSPR_DIR=$HOME/nspr \
    LD_LIBRARY_PATH=$HOME/dist/Debug/lib

RUN set -eux; \
    hg clone https://hg.mozilla.org/projects/nss "$NSS_DIR"; \
    hg clone https://hg.mozilla.org/projects/nspr "$NSPR_DIR"

RUN "$NSS_DIR"/build.sh --static -Ddisable_tests=1

# END stuff from mt

# START stuff from grover

#RUN git clone https://github.com/mozilla/neqo

RUN git clone https://github.com/agrover/neqo
RUN cd neqo && git checkout qns && cargo build && cp target/debug/neqo-client target && cp target/debug/neqo-http3-server target && rm -rf target/debug && mkdir -p downloads
RUN mkdir -p /logs/qlog


# END stuff from grover

COPY setup.sh .
RUN chmod +x setup.sh

COPY run_endpoint.sh .
RUN chmod +x run_endpoint.sh

RUN wget https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh && chmod +x wait-for-it.sh

ENTRYPOINT [ "/run_endpoint.sh" ]

