FROM golang:1.20-alpine AS builder

WORKDIR /app
RUN go install github.com/shazow/ssh-chat/cmd/ssh-chat@latest

FROM alpine:latest

# Cloudflare Tunnel (cloudflared) yükləyirik
RUN apk add --no-cache curl libc6-compat \
    && curl -L --output /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 \
    && chmod +x /usr/local/bin/cloudflared

COPY --from=builder /go/bin/ssh-chat /usr/local/bin/ssh-chat

EXPOSE 2222

# Eyni anda həm ssh-chat-i, həm də Cloudflare tünelini işə salırıq
CMD ssh-chat --bind "0.0.0.0:2222" & cloudflared access tcp --hostname 0.0.0.0:2222 --url tcp://127.0.0.1:2222
