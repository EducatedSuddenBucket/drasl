# ---- Build stage ----
FROM debian:bookworm-slim AS build

RUN apt-get update && apt-get install -y --no-install-recommends \
    make golang gcc nodejs npm ca-certificates git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /src
COPY . .

# Builds the Go binary + frontend assets, then installs to
# /usr/local/bin, /usr/share/drasl, and /etc/drasl (default config)
RUN make && make install

# ---- Runtime stage ----
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /usr/local/bin/drasl /usr/local/bin/drasl
COPY --from=build /usr/share/drasl /usr/share/drasl

# Your own config, baked in
COPY config.toml /etc/drasl/config.toml

EXPOSE 10000
CMD ["drasl"]
