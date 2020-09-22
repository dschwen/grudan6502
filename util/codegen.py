#!/usr/bin/env python

import numpy as np
import sys

tables = ''

# generate y table
tables += 'block_rts_table:\n'
for yy in range(11):
    tables += "\t.word block_y%d-1\n" % yy

# generate x subtables
for yy in range(11):
    tables += "block_y%d_rts_table:\n" % yy
    for xx in range(11):
        tables += "\t.word block_y%dx%d-1\n" % (yy, xx)


code = 'block: lda $23\n\tasl\n\ttax\n\tlda block_rts_table+1, x\n\tpha\n\tlda block_rts_table, x\n\tpha\n\trts\n';

# generate jump code
for yy in range(11):
    code += "block_y%d: lda $22\n\tasl\n\ttax\n\tlda block_y%d_rts_table+1, x\n\tpha\n\tlda block_y%d_rts_table, x\n\tpha\n\trts\n" % (yy, yy, yy);

# generate blitter code
for yy in range(11):
    for xx in range(11):
        code += "block_y%dx%d:\n" % (yy, xx)

gbase = 0x6800

# iterate over blocks
for yy in range(11):
    for xx in range(11):
        code += "block_y%dx%d:\n\tlda #$ff\n" % (yy, xx)

        for yi in range(16):
            for xi in range(2):
                x = xx * 2 +xi
                y = yy*16 + yi;

                spriteid  = x // 3
                spriterow = y % 21
                spritecol = x % 3
                bit = 7 - (x % 8)
                base = y // 16
                mem = gbase + (base * 8 + spriteid) * 64 + spriterow * 3 + spritecol;

                code += "\tsta ${:04x}\n".format(mem)

        code += '\trts\n'

print code
print tables
