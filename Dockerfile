FROM golang:1.20-alpine AS builder

WORKDIR /app
RUN go install github.com/shazow/ssh-chat/cmd/ssh-chat@latest

FROM alpine:latest

# Ngrok-un rəsmi Alpine deposunu əlavə edib yükləyirik
RUN apk add --no-cache curl ca-certificates \
    && curl -s https://ngrok-agent.s3.amazonaws.com/ngrok.asc | apk add --allow-untrusted - \
    && echo "https://ngrok-agent.s3.amazonaws.com/alpine/v3.18/main" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache ngrok

COPY --from=builder /go/bin/ssh-chat /usr/local/bin/ssh-chat

EXPOSE 2222

# Sizin Ngrok tokeniniz
ENV NGROK_AUTHTOKEN="3Hx3Nt4YrYgWhBCJ372OcEd3aXX_5EvsfbMP3JPz7CfeuUiS9"

CMD ssh-keygen -A && \
    ngrok config add-authtoken $NGROK_AUTHTOKEN && \
    ssh-chat --bind "0.0.0.0:2222" --identity /etc/ssh/ssh_host_ed25519_key & \
    sleep 3 && \
    ngrok tcp 2222
