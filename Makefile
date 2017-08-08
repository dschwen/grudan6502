all: grudan.d64

grudan.prg: grudan.s
	cl65 -o grudan.prg -u __EXEHDR__ -t c64 -C c64-asm.cfg grudan.s

grudan.d64: grudan.prg
	c1541 -format grudan,01 d64 grudan.d64 -write grudan.prg grudan.prg

clean:
	rm -f grudan.d64 grudan.prg

run: grudan.d64
	x64 -autostart grudan.d64
