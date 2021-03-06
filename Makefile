SHELL=/usr/bin/env bash -o pipefail

all: lint test build
.PHONY: all

build:
	go build ./cmd/...
.PHONY: build

install:
	go install ./cmd/...
.PHONY: install

test:
	go test ./...
.PHONY: test

validate-vendor:
	GO111MODULE=on GOPROXY=https://proxy.golang.org go mod tidy
	GO111MODULE=on GOPROXY=https://proxy.golang.org go mod vendor
	git status -s ./vendor/ go.mod go.sum
	test -z "$$(git status -s ./vendor/ go.mod go.sum)"
.PHONY: validate-vendor

lint:
	gofmt -s -l $(shell go list -f '{{ .Dir }}' ./... ) | grep ".*\.go"; if [ "$$?" = "0" ]; then gofmt -s -d $(shell go list -f '{{ .Dir }}' ./... ); exit 1; fi
	go vet ./...
.PHONY: lint

format:
	gofmt -s -w $(shell go list -f '{{ .Dir }}' ./... )
.PHONY: format

integration: integration-prowgen integration-pj-rehearse
.PHONY: integration

integration-prowgen:
	test/prowgen-integration/run.sh
	test/prowgen-integration/run.sh subdir
.PHONY: integration-prowgen

integration-pj-rehearse:
	test/pj-rehearse-integration/run.sh
.PHONY: integration-pj-rehearse

check-breaking-changes:
	test/validate-prowgen-breaking-changes.sh
.PHONY: check-breaking-changes
