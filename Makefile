CFLAGS = $(shell pkg-config --cflags sdl3)
LDFLAGS = $(shell pkg-config --libs sdl3)

compile:
	gprbuild -Ppong.gpr -cargs $(CFLAGS) -largs $(LDFLAGS)

bundle:
	mkdir -p build/pong.app/Contents/MacOS
	mkdir -p build/pong.app/Contents/Resources
	mkdir -p build/pong.app/Contents/Frameworks
	echo "APPL????" > build/pong.app/Contents/PkgInfo
	cp build/pong build/pong.app/Contents/MacOS

run:
	./build/pong
