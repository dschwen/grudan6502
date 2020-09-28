#!/usr/bin/env python3

import sys

gbase = 0x6800

data = [[],[],[],[]]

def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]

def print_bytes(lst):
    for c in chunks(lst, 12):
        print('.byte ', ', '.join(["${:02x}".format(i) for i in c]))


# iterate over blocks
def spritelookup():
    for yy in range(11):
        for x in range(22):
            # top row in the block
            ya = yy*16;

            # bottom row in the block
            yb = yy*16 + 15;

            spriteid  = x // 3
            spritecol = x % 3

            spriterow1 = ya % 21
            spriterow2 = yb % 21

            mem1 = gbase + (yy * 8 + spriteid) * 64 + spriterow1 * 3 + spritecol;
            mem2 = gbase + (yy * 8 + spriteid) * 64 + spriterow2 * 3 + spritecol;

            if spriterow2 < spriterow1:
                # value to put in y register
                if x == 0:
                    data[0] += [spriterow2 * 3]
                    data[2] += [(14 - spriterow2)*3]

                # low byte BL of basis address sta $BHBL,y
                if spriterow2 * 3 > mem2 & 0xff:
                  print("problem ", x, yy)
                data[1] += [(mem2 - spriterow2 * 3) & 0xff]
                data[3] += [mem1 & 0xff]
            else:
                # value to put in y register
                if x == 0:
                    data[0] += [15*3]
                    data[2] += [0xff]

                # low byte BL of basis address sta $BHBL,y
                data[1] += [mem1 & 0xff]
                data[3] += [0]

    data[1] += [0] * (256 - len(data[1]))
    data[3] += [0] * (256 - len(data[3]))

    return data
