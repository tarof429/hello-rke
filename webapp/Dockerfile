FROM golang:1.15-alpine AS builder
WORKDIR '/src'
COPY main.go ./
COPY go.mod ./
RUN go build -o /app main.go && \
    rm -rf /src

FROM golang:1.15-alpine AS prod
COPY --from=builder /app /

EXPOSE 8090

ENTRYPOINT [ "/app" ]
