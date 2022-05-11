#!/usr/bin/env python3
import os
import struct
import glob
import binascii
from elftools.elf.elffile import ELFFile

regfile = None
memory = None
def reset():
  global regfile, memory
#   regfile = Regfile()
  # 16kb at 0x80000000
  memory = b'\x00'*0x4000



def ws(addr, dat):
  global memory
  print(hex(addr), len(dat))
  addr -= 0x80000000
  assert addr >=0 and addr < len(memory)
  memory = memory[:addr] + dat + memory[addr+len(dat):]




if __name__ == "__main__":
  if not os.path.isdir('test-cache'):
    os.mkdir('test-cache')
  for x in glob.glob("riscv-tests/isa/rv32ui-p-add"):
    if x.endswith('.dump'):
      continue
    with open(x, 'rb') as f:
      reset()
      print("test", x)
      e = ELFFile(f)
      for s in e.iter_segments():
        print(s.header)
        ws(s.header.p_paddr, s.data())
    #   with open("test-cache/%s" % x.split("/")[-1], "wb") as g:
    #     g.write(b'\n'.join([binascii.hexlify(memory[i:i+4][::-1]) for i in range(0,len(memory),4)]))
    #     #g.write(b'\n'.join([binascii.hexlify(memory[i:i+1]) for i in range(0,len(memory))]))
    #   inscnt = 0
    #   print("  ran %d instructions" % inscnt)
      break
