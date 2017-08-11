#!/usr/bin/env python

from PIL import Image
import numpy as np
import sys

im = Image.open(sys.argv[1])
indexed = np.array(im)
width = indexed.shape[1]
height = indexed.shape[0]

if width != 192 or height != 189 :
  print "Image needs to be 192x189"
  sys.exit(1)

# final sprite bytes
data = [0x00, 0x2e]

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

          c = indexed[y][x]
          if c == 0 :
            byte += 1 << bit

        data.append(byte)

    # append the unused 64th byte
    data.append(0)

with open(sys.argv[2], 'wb') as f :
  f.write(bytearray(data))
