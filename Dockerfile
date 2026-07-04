# ---- Build stage ----
FROM golang:1.25-alpine AS build

RUN apk add --no-cache make gcc musl-dev nodejs npm git ca-certificates

WORKDIR /src
COPY . .
RUN make && make install

# ---- Runtime stage ----
FROM alpine:3.20

RUN apk add --no-cache ca-certificates python3 sqlite py3-pip \
    && pip install --no-cache-dir --break-system-packages -U huggingface_hub

COPY --from=build /usr/bin/drasl /usr/bin/drasl
COPY --from=build /usr/share/drasl /usr/share/drasl
COPY config.toml /etc/drasl/config.toml
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 10000
ENTRYPOINT ["/entrypoint.sh"]
