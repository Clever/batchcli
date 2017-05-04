include golang.mk
.DEFAULT_GOAL := test # override default goal set in library makefile

VERSION := $(shell cat VERSION)
SHELL := /bin/bash
PKG = github.com/Clever/batchcli/cmd
PKGS := $(shell go list ./... | grep -v /vendor)
EXECUTABLE := batchcli
BUILDS := \
	build/$(EXECUTABLE)-v$(VERSION)-linux-amd64
COMPRESSED_BUILDS := $(BUILDS:%=%.tar.gz)
RELEASE_ARTIFACTS := $(COMPRESSED_BUILDS:build/%=release/%)
.PHONY: test $(PKGS) clean release install_deps

$(eval $(call golang-version-check,1.8))

all: test build

test: $(PKGS)

$(GOPATH)/bin/glide:
	@go get github.com/Masterminds/glide

$(PKGS): golang-test-all-deps cmd/version.go
	$(call golang-test-all,$@)

build/*: cmd/version.go
cmd/version.go: VERSION
	@echo 'package main' > $@
	@echo '' >> $@  # Write a go file that lints :)
	@echo '// Version denotes the version of the executable' >> $@ # golint compliance
	echo 'const Version = "$(VERSION)"' >> $@

build/$(EXECUTABLE)-v$(VERSION)-darwin-amd64:
	GOARCH=amd64 GOOS=darwin go build -o "$@/$(EXECUTABLE)" $(PKG)
build/$(EXECUTABLE)-v$(VERSION)-linux-amd64:
	GOARCH=amd64 GOOS=linux go build -o "$@/$(EXECUTABLE)" $(PKG)
build: cmd/version.go $(BUILDS) 

%.tar.gz: %
	tar -C `dirname $<` -zcvf "$<.tar.gz" `basename $<`

$(RELEASE_ARTIFACTS): release/% : build/%
	mkdir -p release
	cp $< $@

release: $(RELEASE_ARTIFACTS)

clean:
	rm -rf build release
	rm cmd/version.go

install_deps: $(GOPATH)/bin/glide
	@$(GOPATH)/bin/glide install
