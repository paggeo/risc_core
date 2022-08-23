#!/usr/bin/env python3
import os
import struct
import glob
import binascii
from elftools.elf.elffile import ELFFile
from enum import Enum

PC = 32
regfile = None
memory = None

regnames = \
  ['x0', 'ra', 'sp', 'gp', 'tp'] + ['t%d'%i for i in range(0,3)] + ['s0', 's1'] +\
  ['a%d'%i for i in range(0,8)] +\
  ['s%d'%i for i in range(2,12)] +\
  ['t%d'%i for i in range(3,7)] + ["PC"]

class Regfile:
  def __init__(self):
    self.regs = [0]*33
  def __getitem__(self, key):
    return self.regs[key]
  def __setitem__(self, key, value):
    if key == 0:
      return
    self.regs[key] = value & 0xFFFFFFFF

def reset():
  global regfile, memory
  regfile = Regfile()
  # 16kb at 0x80000000
  memory = b'\x00'*0x4000

def ws(addr, dat):
  global memory
  #print(hex(addr), len(dat))
  #addr -= 0x80000000
  assert addr >=0 and addr < len(memory)
  memory = memory[:addr] + dat + memory[addr+len(dat):]

class Ops(Enum):
  LUI = 0b0110111    # load upper immediate
  LOAD = 0b0000011
  STORE = 0b0100011

  AUIPC = 0b0010111  # add upper immediate to pc
  BRANCH = 0b1100011
  JAL = 0b1101111
  JALR = 0b1100111

  IMM = 0b0010011
  OP = 0b0110011

  MISC = 0b0001111
  SYSTEM = 0b1110011

class Funct3(Enum):
  ADD = SUB = ADDI = 0b000
  SLLI = 0b001
  SLT = SLTI = 0b010
  SLTU = SLTIU = 0b011

  XOR = XORI = 0b100
  SRL = SRLI = SRA = SRAI = 0b101
  OR = ORI = 0b110
  AND = ANDI = 0b111

  BEQ = 0b000
  BNE = 0b001
  BLT = 0b100
  BGE = 0b101
  BLTU = 0b110
  BGEU = 0b111

  LB = SB = 0b000
  LH = SH = 0b001
  LW = SW = 0b010
  LBU = 0b100
  LHU = 0b101

  # stupid instructions below this line
  ECALL = 0b000
  CSRRW = 0b001
  CSRRS = 0b010
  CSRRC = 0b011
  CSRRWI = 0b101
  CSRRSI = 0b110
  CSRRCI = 0b111


def step():
  # *** Instruction Fetch ***
  ins = r32(regfile[PC])

  # *** Instruction decode and register fetch ***
  def gibi(s, e):
    return (ins >> e) & ((1 << (s-e+1))-1)

  #opcode = Ops(gibi(6, 0))
  opcode = gibi(6, 0)
  #funct3 = Funct3(gibi(14, 12))
  #funct7 = gibi(31, 25)
  #imm_i = sign_extend(gibi(31, 20), 12)
  #imm_s = sign_extend(gibi(31, 25)<<5 | gibi(11, 7), 12)
  #imm_b = sign_extend((gibi(32, 31)<<12) | (gibi(30, 25)<<5) | (gibi(11, 8)<<1) | (gibi(8, 7)<<11), 13)
  #imm_u = sign_extend(gibi(31, 12)<<12, 32)
  #imm_j = sign_extend((gibi(32, 31)<<20) | (gibi(30, 21)<<1) | (gibi(21, 20)<<11) | (gibi(19, 12)<<12), 21)

  if opcode == 3 : 
    print(f"Ops:{opcode}\t rd:{gibi(11,7)}\t funct3:{gibi(14,12)}\t rs1:{gibi(19,15)}\t imm:{gibi(31,20)}")
  #if opcode == 3 or opcode == 35 or opcode == 19 or opcode == 51:
    #print(ins)
    #print(opcode, end = "\t")
    #print(gibi(11,7))
  regfile[PC] = regfile[PC] + 4
  return True


def r32(addr):
  addr -= 0x80000000
  if addr < 0 or addr >= len(memory):
    raise Exception("read out of bounds: 0x%x" % addr)
  return struct.unpack("<I", memory[addr:addr+4])[0]

if __name__ == "__main__":
  for x in glob.glob("add.o"):
    if x.endswith('.n'):
      continue
    if x.endswith('.s'):
      continue
    with open(x, 'rb') as f:
      reset()
      print("test", x)
      e = ELFFile(f)
      print(e)
      for s in e.iter_segments():
        print(s.header)
        if s.header.p_type != 'PT_LOAD' or s.header.p_flags != 5:
          continue
        ws(s.header.p_paddr, s.data())
      with open("test_bin", "wb") as g:
        g.write(b'\n'.join([binascii.hexlify(memory[i:i+4][::-1]) for i in range(0,len(memory),4)]))
      regfile[PC] = 0x80000000
      inscnt = 0
      while step():
        inscnt += 1
      print("  ran %d instructions" % inscnt)
