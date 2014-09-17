all: test

iospec2/iospec:
	@git submodule init

test: iospec2/iospec mime-type-spec.io mime-types-spec.io
	@iospec2/iospec
