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
ASFLAGS = -g --cpu $(CPU) -t c64 --include-dir src/

LD = cl65
#Define segments & files in config.cfg
LDFLAGS =  -t c64 -C config.cfg -u __EXEHDR__ -m labels.txt -Ln symbols -o $(OUTPUT)

OBJS = \
	$(MAIN).o

all: $(DISKFILENAME)

%.o : %.s
	$(AS) $(ASFLAGS) $*.s -o $@

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

table.inc: util/codegen2.py
	./util/codegen2.py > table.inc

clean:
	rm -f $(MAIN).d64 $(MAIN).prg *.o

run: $(DISKFILENAME)
	$(X64) -autostart $(DISKFILENAME) -warp

monitor: $(DISKFILENAME)
	echo "load_labels \"$(MAIN).lbl\"" > debug.cmd
	$(X64) -autostart $(MAIN).d64 -nativemonitor

c64debugger: $(DISKFILENAME) $(MAIN).lbl
	"$(C64DEBUGGER)" -autorundisk -d64 $(MAIN).d64 -symbols $(MAIN).lbl
