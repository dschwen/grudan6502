#!/usr/bin/env python

import sys
import png
import numpy
try:
    from itertools import imap
except:
    imap = map

r = png.Reader(sys.argv[1])
im = r.asRGB8()
width = im[0]
height = im[1]
rgb = numpy.vstack(imap(numpy.uint8, im[2]))

if width != 192 or height != 189 :
  print("Image needs to be 192x189")
  sys.exit(1)

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

        c = rgb[y][x * 3]
        if c == 0 :
          data[mem] += 1 << bit

with open(sys.argv[2], 'wb') as f :
  f.write(bytearray(data))
