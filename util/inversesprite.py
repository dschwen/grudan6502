#!/usr/bin/env python3

import numpy as np
import sys

gbase = 0x6800

# iterate over image pixels
for y in range(11*16):
    line = "{:3}".format(y) + ':'
    for x in range(12*2):
        spriteid  = x // 3
        spriterow = y % 21
        spritecol = x % 3
        bit = 7 - (x % 8)
        base = y // 16
        mem = gbase + (base * 8 + spriteid) * 64 + spriterow * 3 + spritecol;

        line += ' ' + "{:04x}".format(mem)
        if x % 3 == 2:
            line += ' '

    print(line)
    if y % 16 == 15:
        print('\n')
