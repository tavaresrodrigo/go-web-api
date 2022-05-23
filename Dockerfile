FROM golang:1.17-alpine

WORKDIR /app 

COPY go.mod /app
COPY go.sum /app
RUN go mod download

COPY *.go /app

RUN go build -o /go-web-api

EXPOSE 8080

CMD ["/go-web-api"]