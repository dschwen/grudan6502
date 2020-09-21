#!/usr/bin/env python

import numpy as np
import sys

# iterate over image pixels
for y in range(11*16):
    line = "{:3}".format(y) + ':'
    for x in range(11*2):
        spriteid  = x // 3
        spriterow = y % 21
        spritecol = x % 3
        bit = 7 - (x % 8)
        base = y // 16
        mem = (base * 8 + spriteid) * 64 + spriterow * 3 + spritecol;

        line += ' ' + "{:04x}".format(mem)
        if x % 3 == 2:
            line += ' '

    print(line)
    if y>0 and y % 16 == 0:
        print
