#!/usr/bin/env python3

import sys

from spritelookup import spritelookup, print_bytes
from png2tiles import convert

#
# Sprite layer address lookup
#

data = spritelookup()

print("yval1:")
print_bytes(data[0])
print("yval2:")
print_bytes(data[2])

print('.segment "ADATA"')

print("lowbase1:")
print_bytes(data[1])
print("lowbase2:")
print_bytes(data[3])

#
# tile data
#

addr = convert("res/tiles.png", "res/tiles.dat")
print("lo_bitsprite = %s" % "${:02x}".format(addr[0] & 0xff))
print("hi_bitsprite = %s" % "${:02x}".format(addr[0] >> 8))
print("lo_bithires = %s" % "${:02x}".format(addr[1] & 0xff))
print("hi_bithires = %s" % "${:02x}".format(addr[1] >> 8))

print("colordata = %s" % "${:04x}".format(addr[2]))

#
# hires address table
#

print("hiresaddr:")
hiadr = []
for y in range(22):
    hiadr.append(0x4000 + 8*41 + 8*40*y)
print('.word ', ', '.join(["${:04x}".format(i) for i in hiadr]))

#
# color ram address table
#

print("coloraddr:")
hiadr = []
for y in range(11):
    hiadr.append(80 * y + 41)
print('.word ', ', '.join(["${:04x}".format(i) for i in hiadr]))
