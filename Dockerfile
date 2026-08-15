FROM golang:1.20-alpine AS builder

WORKDIR /app
RUN go install github.com/shazow/ssh-chat/cmd/ssh-chat@latest

FROM alpine:latest

# Ngrok-u birbaşa rəsmi arxivdən yükləyib çıxarırıq
RUN apk add --no-cache curl tar \
    && curl -sSL https://bin.equinox.io/c/b4p23AR424r/ngrok-v3-stable-linux-amd64.tgz -o ngrok.tgz \
    && tar -xzf ngrok.tgz -C /usr/local/bin \
    && rm ngrok.tgz

COPY --from=builder /go/bin/ssh-chat /usr/local/bin/ssh-chat

EXPOSE 2222

ENV NGROK_AUTHTOKEN="3Hx3Nt4YrYgWhBCJ372OcEd3aXX_5EvsfbMP3JPz7CfeuUiS9"

CMD ssh-keygen -A && \
    ngrok config add-authtoken $NGROK_AUTHTOKEN && \
    ssh-chat --bind "0.0.0.0:2222" --identity /etc/ssh/ssh_host_ed25519_key & \
    sleep 3 && \
    ngrok tcp 2222
