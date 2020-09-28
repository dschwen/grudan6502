#!/usr/bin/env python3

import sys
import png
import numpy

def convert(infile, outfile):
    pal = [0x000000, 0xffffff, 0x883932, 0x67b6bd, 0x8b3f96, 0x55a049,
           0x40318d, 0xbfce72, 0x8b5429, 0x574200, 0xb86962, 0x505050,
           0x787878, 0x94e089, 0x7869c4, 0x9f9f9f]
    r = png.Reader(infile)
    im = r.asRGBA8()
    width = im[0]
    height = im[1]

    rgb = list(im[2])

    # first sprite then hires, then colors
    data = [[], [] ,[]]

    # iterate over image pixels
    tile = 0
    # for yy in range(2):
    #     for xx in range(4):

    for yy in range(2):
        for xx in range(4):
            colors = [0] * 4

            sprite = [[0 for x in range(16)] for x in range(2)]
            hires = [[0 for x in range(16)] for x in range(2)]

            for sx in [0,1]:
                for sy in [0,1]:
                    # analyze colors
                    found = [0] * 16
                    block =  [[0 for x in range(8)] for x in range(8)]
                    for px in range(8):
                        for py in range(8):
                            x = xx * 16 + sx * 8 + px
                            y = yy * 16 + sy * 8 + py

                            r = rgb[y][x*4]
                            g = rgb[y][x*4+1]
                            b = rgb[y][x*4+2]
                            a = rgb[y][x*4+3]

                            h = (r << 16) + (g << 8) + b
                            idx = pal.index(h)
                            found[idx] += 1

                            block[py][px] = idx

                    # make sure only two non black colors are used
                    c = [i+1 for i, e in enumerate(found[1:]) if e != 0]
                    if len(c) > 2:
                        print("too many colors at tile (%d,%d) subtile (%d,%d)" % (xx, yy, sx, sy))
                        print(found)

                    c += [0]

                    for px in range(8):
                        for py in range(8):
                            bit = 7 - px
                            if block[py][px] == 0:
                                sprite[sx][sy*8+py] += 1 << bit

                            elif block[py][px] == c[0]:
                                hires[sx][sy*8+py] += 1 << bit

                    colors[sy*2 + sx] = c[1] + (c[0] << 4)

            # serialize sprite data (column wise from bottom to top)
            for col in [0,1]:
                for line in range(15,-1, -1):
                    data[0].append(sprite[col][line])

            # serialize hires data (in hires format, 8lines 4 times)
            for row in [0,1]:
                for col in [0,1]:
                    for line in range(8):
                        data[1].append(hires[col][row*8+line])

            # add the 4 color bytes
            data[2] += colors

    # pad sprite and hires bitap data to multiple of 256
    for i in [0,1]:
        pad = 256 - len(data[i]) % 256
        if pad < 256:
            data[i] += [0] * pad

    # integrity check
    size = len(data[0])
    if size != len(data[1]):
        print("sprite and hires data should have the same size")
        sys.exit(1)

    # base address 0x8000
    base = 0x8000

    # serialize
    file = [base & 0xff, base >> 8]
    for i in range(3):
        file += data[i]

    with open(outfile, 'wb') as f :
        f.write(bytearray(file))

    return (base, base + size, base + 2*size)
