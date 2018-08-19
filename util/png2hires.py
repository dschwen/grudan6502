#!/usr/bin/env python

import sys
import png
import numpy
import itertools

r = png.Reader(sys.argv[1])
im = r.asRGB8()
width = im[0]
height = im[1]
rgb = numpy.vstack(itertools.imap(numpy.uint8, im[2]))

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

        c = rgb[y][x * 3]
	if c != 0 :
          byte += 1 << bit

      data.append(byte)

with open(sys.argv[2], 'wb') as f :
  f.write(bytearray(data))
