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

# iterate over the 8px tall screen rows
for spriterow in range(9) :
  # iterate over the sprites in a row
  for spritecol in range(8) :
    # iterate over the sprite rows
    for row in range(21) :
      # iterate over the sprite colums
      for col in range(3) :
        # iterate over the bits
        byte = 0
        for bit in range(8) :
          x = 24 * spritecol + 8 * col + 7 - bit
          y = 21 * spriterow + row

          c = rgb[y][x * 3]
          if c == 0 :
            byte += 1 << bit

        data.append(byte)

    # append the unused 64th byte
    data.append(0)

with open(sys.argv[2], 'wb') as f :
  f.write(bytearray(data))
