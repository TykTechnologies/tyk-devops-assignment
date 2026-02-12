# --- build stage ---
FROM golang:1.26-alpine AS builder
ARG TARGETARCH
RUN apk add --no-cache make git
WORKDIR /app
COPY go.mod .
RUN go mod download
COPY . .
RUN make build-static ARCH="${TARGETARCH}"

# --- runtime stage ---
FROM scratch
ARG TARGETARCH
COPY --from=builder /app/dist/httpbin-static-${TARGETARCH} /httpbin
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/httpbin"]
