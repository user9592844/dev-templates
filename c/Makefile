# Example of a Makefile command runner for C development

mkfile_path := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

all: clean build install

clean:
	rm -rf "$(mkfile_path)build"

build:
	cd "$(mkfile_path)cmake" && cmake -B "$(mkfile_path)build" -G Ninja

install:
	cmake --build "$(mkfile_path)build"

test-all: test-clean test-build test-install

test-clean:
	rm -rf "$(mkfile_path)unit-tests/cmake/build"

test-build:
	cd "$(mkfile_path)unit-tests/cmake" && cmake -B "$(mkfile_path)unit-tests/build" -G Ninja

test-install:
	cmake --build "$(mkfile_path)unit-tests/build"
