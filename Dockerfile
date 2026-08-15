FROM golang:1.20-alpine AS builder

WORKDIR /app
RUN go install github.com/shazow/ssh-chat/cmd/ssh-chat@latest

FROM alpine:latest

# Lazımi paketləri yükləyirik (openssh-client pinggy tüneli üçündür)
RUN apk add --no-cache openssh-client

COPY --from=builder /go/bin/ssh-chat /usr/local/bin/ssh-chat

EXPOSE 2222

# SSH açarını avtomatik yaradıb, ssh-chat və Pinggy-ni eyni anda işə salırıq
CMD ssh-keygen -A && \
    ssh-chat --bind "0.0.0.0:2222" --identity /etc/ssh/ssh_host_ed25519_key & \
    sleep 3 && \
    ssh -o StrictHostKeyChecking=no -p 443 -R0:localhost:2222 tcp@a.pinggy.io
