FROM golang:1.22 AS build
WORKDIR /app

COPY go.mod ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o server .

FROM alpine:3.20
WORKDIR /app
COPY --from=build /app/server ./server
COPY templates ./templates

EXPOSE 8080
CMD ["./server"]