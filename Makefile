MAIN ?= raster

ifneq (,$(wildcard ~/Downloads/C64\ 65XE\ Debugger\ v0.64.56.4/C64\ Debugger.app/Contents/MacOS/C64Debugger))
  C64DEBUGGER := ~/Downloads/C64\ 65XE\ Debugger\ v0.64.56.4/C64\ Debugger.app/Contents/MacOS/C64Debugger
else ifneq (,$(wildcard /usr/local/bin/c64debugger))
  C64DEBUGGER := /usr/local/bin/c64debugger
endif

all: $(MAIN).d64

$(MAIN).prg: $(MAIN).s
	cl65 -g -o $(MAIN).prg -u __EXEHDR__ -t c64 -C c64-asm.cfg $(MAIN).s -Ln $(MAIN).lbl

$(MAIN).d64: $(MAIN).prg res/daniel.dat res/daniel_sprite.dat res/stripes.dat
	c1541 -format $(MAIN),01 d64 $(MAIN).d64 \
		-write $(MAIN).prg $(MAIN).prg \
		-write res/daniel.dat a \
		-write res/daniel_sprite.dat b \
		-write res/stripes.dat c

res/daniel.dat: res/daniel.png util/png2hires.py
	python util/png2hires.py res/daniel.png res/daniel.dat

res/stripes.dat: util/png2sprite.py
	python util/dummysprite.py res/stripes.dat

res/daniel_sprite.dat: res/daniel_sprite.png util/png2sprite.py
	python util/png2sprite.py res/daniel_sprite.png res/daniel_sprite.dat

clean:
	rm -f $(MAIN).d64 $(MAIN).prg

run: $(MAIN).d64
	x64 -autostart $(MAIN).d64 -warp

monitor: $(MAIN).d64
	echo "load_labels \"$(MAIN).lbl\"" > debug.cmd
	x64 -autostart $(MAIN).d64 -moncommands debug.cmd -nativemonitor

c64debugger: $(MAIN).d64 $(MAIN).lbl
	$(C64DEBUGGER) -autorundisk -d64 $(MAIN).d64 -symbols $(MAIN).lbl
