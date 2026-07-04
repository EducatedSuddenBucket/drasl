# ---- Build stage ----
FROM golang:1.25-bookworm AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    make gcc nodejs npm ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

RUN make && make install

# ---- Runtime stage ----
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/bin/drasl /usr/bin/drasl
COPY --from=build /usr/share/drasl /usr/share/drasl

COPY config.toml /etc/drasl/config.toml

EXPOSE 10000
CMD ["drasl"]
