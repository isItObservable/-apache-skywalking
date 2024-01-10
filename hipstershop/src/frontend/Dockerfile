FROM apache/skywalking-go:0.3.0-go1.19  as builder
WORKDIR /src


COPY . .
RUN go mod tidy
RUN go mod download
RUN go build  -toolexec=skywalking-go-agent   -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o frontend

FROM ubuntu as release

WORKDIR /src
COPY --from=builder /src/frontend /src/server
COPY ./templates ./templates
COPY ./static ./static
ENV GOTRACEBACK=single
EXPOSE 8080
ENTRYPOINT ["/src/server"]