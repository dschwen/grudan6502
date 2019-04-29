#!/usr/bin/env python

import numpy as np
import sys

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

          c = (x+y) % 5;
          if c < 3 :
            byte += 1 << bit

        data.append(byte)

    # append the unused 64th byte
    data.append(0)

with open(sys.argv[1], 'wb') as f :
  f.write(bytearray(data))
