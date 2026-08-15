FROM golang:1.20-alpine AS builder
RUN apk add --no-network --no-cache git make
RUN go install github.com/shazow/ssh-chat/cmd/ssh-chat@latest

FROM alpine:latest
COPY --from=builder /go/bin/ssh-chat /usr/local/bin/ssh-chat
EXPOSE 2222
CMD ["ssh-chat", "--bind", "0.0.0.0:2222"]
