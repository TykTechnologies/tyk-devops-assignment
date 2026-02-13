# --- build stage ---
FROM golang:1.26-alpine AS builder

ARG TARGETARCH
ARG VERSION

RUN apk add --no-cache make git

WORKDIR /app
COPY . .

# Build static binary
RUN make build-static ARCH="${TARGETARCH}" VERSION="${VERSION}"

# --- runtime stage ---
FROM scratch

ARG TARGETARCH

COPY --from=builder /app/bin/httpbin-static-${TARGETARCH} /httpbin
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

LABEL org.opencontainers.image.title="HTTPBin" \
      org.opencontainers.image.description="HTTP Request & Response Service"

ENTRYPOINT ["/httpbin"]
