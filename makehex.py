#!/usr/bin/env python3

import sys
import binascii
with open(sys.argv[1], "rb") as f:
  writeFile = open(sys.argv[2],"w")
  memory = f.read()
#   print('\n'.join([binascii.hexlify(memory[i:i+4][::-1]).decode('utf-8') for i in range(0,len(memory),4)]))
  writeFile.write('\n'.join([binascii.hexlify(memory[i:i+4][::-1]).decode('utf-8') for i in range(0,len(memory),4)]))
  writeFile.close()