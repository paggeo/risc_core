#!/usr/bin/env python3
import os
import struct
import glob
import binascii
from elftools.elf.elffile import ELFFile


if __name__ == "__main__":
  f = open("hex", 'r')
  for line in f:
    line = line.replace('\n','')
    line = line.replace(' ','')

    a = [line[2*x]+line[2*x+1] for x in range(len(line)//2)]
    a = a[::-1]
    a = ''.join(a)
    res = "{0:032b}".format(int(a, 16))
    print(res)
