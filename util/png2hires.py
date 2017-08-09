#!/usr/bin/env python 

from PIL import Image
import numpy as np
import sys

im = Image.open(sys.argv[1])
indexed = np.array(im)
width = indexed.shape[1]
height = indexed.shape[0]

if width != 320 or height != 200 :
  print "Image needs to be 320x200"
  sys.exit(1)

# final hires bytes
data = [0x00, 0xA0]

# iterate over the 8px tall screen rows 
for superrow in range(25) :
  # iterate over the screen colums
  for col in range(40) :
    # iterate over the rows of a char position
    for char in range(8) :
      # iterate over the bits
      byte = 0
      for bit in range(8) :
        x = 8 * col + 7 - bit
        y = 8 * superrow + char

        c = indexed[y][x]
	if c == 0 :
          byte += 1 << bit

      data.append(byte)

with open(sys.argv[2], 'wb') as f :
  f.write(bytearray(data))
