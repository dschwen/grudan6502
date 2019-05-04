#!/usr/bin/env python

for i in range(0,16*11):
  base = i / 16
  line = i % 21
  row = i / 21
  print i, base, line, row
