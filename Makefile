MAIN ?= raster

CPU = 6502x
C1541 = c1541

# Also pass symbols to VICE monitor
X64 = x64sc -moncommands symbols
OUTPUT = $(MAIN).prg

DISKFILENAME = $(MAIN).d64
DISKNAME = $(MAIN)
ID = 17

AS = ca65
# Add defines, if needed (-DWHATEVER)
ASFLAGS = -g --cpu $(CPU) --include-dir src/

# $(MAIN).prg: $(MAIN).s
# 	cl65 -g -o $(MAIN).prg -u __EXEHDR__ --cpu 6502x -t c64 -C c64-asm.cfg $(MAIN).s -Ln $(MAIN).lbl

LD = ld65
#Define segments & files in config.cfg
LDFLAGS = -m labels.txt -Ln symbols -o $(OUTPUT) -C config.cfg

OBJS = \
	raster.o

%.o : %.c
	$(AS) $(ASFLAGS) $*.s -o $@

all: $(DISKFILENAME)

$(OUTPUT): $(OBJS) res/daniel.dat res/daniel_sprite.dat res/stripes.dat
	$(LD) $(LDFLAGS) $(OBJS)

# clean:
# 	rm -f src/*.o diskcontents/* labels.txt symbols $(DISKFILENAME)

$(DISKFILENAME): $(OUTPUT) res/daniel.dat res/daniel_sprite.dat res/stripes.dat
	$(C1541) -format $(DISKNAME),01 d64 $(DISKFILENAME) \
		-write $(OUTPUT) $(OUTPUT) \
		-write res/daniel.dat a \
		-write res/daniel_sprite.dat b \
		-write res/stripes.dat c

res/daniel.dat: res/daniel.png util/png2hires.py
	python util/png2hires.py res/daniel.png res/daniel.dat

res/stripes.dat: util/dummysprite.py
	python util/dummysprite.py res/stripes.dat

res/daniel_sprite.dat: res/daniel_sprite.png util/png2sprite.py
	python util/png2sprite.py res/daniel_sprite.png res/daniel_sprite.dat

clean:
	rm -f $(MAIN).d64 $(MAIN).prg

run: $(DISKFILENAME)
	$(X64) -autostart $(DISKFILENAME) -warp

monitor: $(DISKFILENAME)
	echo "load_labels \"$(MAIN).lbl\"" > debug.cmd
	$(X64) -autostart $(MAIN).d64 -nativemonitor

c64debugger: $(DISKFILENAME) $(MAIN).lbl
	$(C64DEBUGGER) -autorundisk -d64 $(MAIN).d64 -symbols $(MAIN).lbl
