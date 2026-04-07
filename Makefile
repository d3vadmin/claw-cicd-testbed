.PHONY: all build test
all: build
build:
	@sh build.sh
test: build
