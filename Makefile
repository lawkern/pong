CFLAGS = $(shell pkg-config --cflags sdl3)
LDFLAGS = $(shell pkg-config --libs sdl3)

compile:
	gprbuild -Ppong.gpr -cargs $(CFLAGS) -largs $(LDFLAGS)

run:
	./build/pong
