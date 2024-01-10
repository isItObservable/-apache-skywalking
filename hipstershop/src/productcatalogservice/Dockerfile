# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM apache/skywalking-go:0.3.0-go1.19 as builder
WORKDIR /build/src
# restore dependencies
COPY . .

RUN go mod tidy
RUN go mod download

# Skaffold passes in debug-oriented compiler flags
ARG SKAFFOLD_GO_GCFLAGS
RUN skywalking-go-agent -inject /build/src
RUN go build -toolexec=skywalking-go-agent -a  -gcflags="${SKAFFOLD_GO_GCFLAGS}" -o productcatalogservice

FROM ubuntu
WORKDIR /src
COPY --from=builder /build/src/productcatalogservice /src/server
COPY products.json .

# Definition of this variable is used by 'skaffold debug' to identify a golang binary.
# Default behavior - a failure prints a stack trace for the current goroutine.
# See https://golang.org/pkg/runtime/
ENV GOTRACEBACK=single

EXPOSE 3550
ENTRYPOINT ["/src/server"]

