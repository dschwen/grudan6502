#!/usr/bin/env python3

import sys

gbase = 0x6800

tables = ''

# iterate over blocks
for yy in range(11):
    for x in range(22):
        # top row in the block
        ya = yy*16;

        # bottom row in the block
        yb = yy*16 + 15;

        spriteid  = x // 3
        spritecol = x % 3

        spriterow1 = ya % 21
        spriterow2 = yb % 21

        mem1 = gbase + (yy * 8 + spriteid) * 64 + spriterow1 * 3 + spritecol;
        mem2 = gbase + (yy * 8 + spriteid) * 64 + spriterow2 * 3 + spritecol;

        if x == 0:
            if spriterow2 < spriterow1:
                print(yy, spriterow1, spriterow2, mem1, mem2)
                print("  ", spriterow2 + 1, mem2 - spriterow2, 15 - spriterow2, mem1)
                for yi in range(16) :
                    print("\t", yi, (yi+ya) % 21)
            else:
                print(yy, spriterow1, spriterow2, mem1, mem2)
                print("* ", 16, mem1, 1, 0)
                for yi in range(16) :
                    print("\t", yi, (yi+ya) % 21)
        mem = gbase + (yy * 8 + spriteid) * 64 + spriterow1 * 3 + spritecol;

#print tables
