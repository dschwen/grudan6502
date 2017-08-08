#!/usr/bin/env python 

import png
import sys

r = png.Reader(filename=sys.argv[1])
(width, height, pixels, meta) = r.asDirect()

if width != 320 or height != 200 :
  print "Image needs to be 320x200"
  sys.exit(1)

row = list(pixels)

# final hires bytes
data = [0,0]

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

        c = row[y][x*3]
        if c > 127 :
          byte += 1 << bit

      data.append(byte)

with open(sys.argv[2], 'wb') as f :
  f.write(bytearray(data))
