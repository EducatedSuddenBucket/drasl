FROM golang:1.25-bookworm AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    make gcc nodejs npm ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN make && make install
RUN which drasl && find / -maxdepth 6 -iname "drasl*" -type f 2>/dev/null
