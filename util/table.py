#!/usr/bin/env python3

import sys

from spritelookup import spritelookup, print_bytes

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
