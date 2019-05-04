#!/usr/bin/env python

import numpy as np
import sys

# sprite file bytes, starting with lo,hi addres
data = [0x00, 0x68] + [0] * (11*8*64)

# iterate over image pixels
for x in range(11*16):
    for y in range(11*16):
        spriteid  = x / 24
        spriterow = y % 21
        spritecol = (x % 24) / 8
        bit = 7 - (x % 8)
        base = y / 16
        mem = 2 + (base * 8 + spriteid) * 64 + spriterow * 3 + spritecol;

        c = (x+y) % 5
        if c < 3 :
          data[mem] += 1 << bit

with open(sys.argv[1], 'wb') as f :
  f.write(bytearray(data))
