.PHONY: all build test fix
all: build
build:
	@sh build.sh
fix: build
test: build
