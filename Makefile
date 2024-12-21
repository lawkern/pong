compile:
	gprbuild -Ppong.gpr -largs $(shell pkg-config --libs sdl3)

run:
	./build/pong
