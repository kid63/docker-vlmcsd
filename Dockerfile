FROM debian:trixie-slim AS builder

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        git \
        patch \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN git clone https://github.com/Wind4/vlmcsd.git .
COPY patches/kms-dangling-pointer.patch /tmp/
RUN patch -p1 < /tmp/kms-dangling-pointer.patch

RUN make


FROM debian:trixie-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/bin/vlmcsd /usr/local/bin/vlmcsd

EXPOSE 1688/tcp

ENTRYPOINT ["/usr/local/bin/vlmcsd"]
CMD ["-D", "-e"]
