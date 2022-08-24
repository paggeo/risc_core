from helper import *

def load_ins(i, rd,rs1,rs2):
  bitwise = []
  bitwise.append("0000011")
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  if i == 'lb':
    bitwise.append("000")
  if i == 'lh':
    bitwise.append("001")
  if i == 'lw':
    bitwise.append("010")
  if i == 'lbu':
    bitwise.append("100")
  if i == 'lhu':
    bitwise.append("101")

  tmp_rs1 = rs1.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rs1)))
  bitwise.append(bindigits(int(rs2),12))

  return bitwise
    
def store_ins(i,rd,rs1,rs2):
  bitwise = []
  bitwise.append("0100011")
  a = bindigits(int(rs2),12)
  bitwise.append(a[7:13])
  if i == 'sb':
    bitwise.append("001")
  if i == 'sh':
    bitwise.append("001")
  if i == 'sw':
    bitwise.append("010")

  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  tmp_rs1 = rs1.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rs1)))
  bitwise.append(a[:7])

  return bitwise

def imm_ins(i,rd,rs1,rs2):
  bitwise = []
  bitwise.append("0010011")
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  tmp_rs1 = rs1.replace('x','')
  a = bindigits(int(rs2),12)
  if i == 'addi':
    bitwise.append("000")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(a)
  if i == 'slti':
    bitwise.append("010")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(a)
  if i == 'sltiu':
    bitwise.append("011")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(a)
  if i == 'xori':
    bitwise.append("100")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(a)
  if i == 'ori':
    bitwise.append("110")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(a)
  if i == 'andi':
    bitwise.append("111")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(a)
  if i == 'slli':
    b = bindigits(int(rs2),5)
    bitwise.append("001")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(b)
    bitwise.append("0000000")
  if i == 'srli':
    b = bindigits(int(rs2),5)
    bitwise.append("101")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(b)
    bitwise.append("0000000")
  if i == 'srai':
    b = bindigits(int(rs2),5)
    bitwise.append("101")
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    bitwise.append(b)
    bitwise.append("0100000")
  return bitwise

def reg_ins(i,rd,rs1,rs2):
  bitwise = []
  bitwise.append("0110011")
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  if i == 'add':
    bitwise.append("000")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'sub':
    bitwise.append("000")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0100000")
  if i == 'sll':
    bitwise.append("001")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'slt':
    bitwise.append("010")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'sltu':
    bitwise.append("011")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'xor':
    bitwise.append("100")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'srl':
    bitwise.append("101")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'sra':
    bitwise.append("101")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0100000")
  if i == 'or':
    bitwise.append("110")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")
  if i == 'and':
    bitwise.append("111")
    tmp_rs1 = rs1.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs1)))
    tmp_rs2 = rs2.replace('x','')
    bitwise.append("{0:05b}".format(int(tmp_rs2)))
    bitwise.append("0000000")

  return bitwise
def branch_ins(i,rd,rs1,rs2):
  bitwise = []
  bitwise.append("1100011")
  a = bindigits(int(rs2),12)
  bitwise.append(a[8:12] + a[1])
  if i == 'beq':
    bitwise.append("000")
  if i == 'bne':
    bitwise.append("001")
  if i == 'blt':
    bitwise.append("100")
  if i == 'bge':
    bitwise.append("101")
  if i == 'bltu':
    bitwise.append("110")
  if i == 'bgeu':
    bitwise.append("111")

  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  tmp_rs1 = rs1.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rs1)))

  bitwise.append(a[0] + a[2:8] )
  return bitwise

def jal_ins(i,rd,rs1):
  bitwise = []
  bitwise.append("1101111")
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  a = bindigits(int(rs1),20)
  bitwise.append(a[0]+a[10:20] + a[9] +  a[1:9] )
  return bitwise

def jalr_ins(i,rd,rs1,rs2):
  bitwise = []
  bitwise.append("1100111")
  
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))
  
  bitwise.append("000")
  
  tmp_rs1 = rs1.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rs1)))

  a = bindigits(int(rs2),12)
  bitwise.append(a)

  return bitwise

def lui_ins(i,rd,rs1):
  bitwise = []
  bitwise.append("0110111")
  
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))

  a = bindigits(int(rs1),20)
  bitwise.append(a)
  
  return bitwise

def auipc_ins(i,rd,rs1):
  bitwise = []
  bitwise.append("0010111")
  
  tmp_rd = rd.replace('x','')
  bitwise.append("{0:05b}".format(int(tmp_rd)))

  a = bindigits(int(rs1),20)
  bitwise.append(a)
  
  return bitwise