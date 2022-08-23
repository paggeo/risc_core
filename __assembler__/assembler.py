#!/usr/bin/env python3


def bindigits(n, bits):
  s = bin(n & int("1"*bits, 2))[2:]
  return ("{0:0>%s}" % (bits)).format(s)

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

def __print_load__(bitwise):
  print('Load:\t Opcode:{:<10s} rd: {:<10s} funct3:{:<10s} rs1:{:<10s} imm:{:<10s}'.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4]))

def __print_store__(bitwise):
  print('Store:\t Opcode:{:<10s} imm:{:<10s} funct3:{:<10s} rs1:{:<10s} rs2:{:<10s} imm:{:<10s}'.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))

def __print_imm__(bitwise):
  if len(bitwise) == 6 :
    print('Imm shamt:\t Opcode:{:<10s} rd: {:<10s} funct3:{:<10s} rs1:{:<10s} shamt:{:<10s} funct7:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))
  else:
    print('Imm:\t Opcode:{:<10s} rd: {:<10s} funct3:{:<10s} rs1:{:<10s} imm[11:0]:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4]))

def __print_reg__(bitwise):
  print('Reg:\t Opcode:{:<10s} rd: {:<10s} funct3:{:<10s} rs1:{:<10s} rs2:{:<10s} funct7:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))

def __print_branch__(bitwise):
  print('Branch:\t Opcode:{:<10s} imm:{:<10s} funct3:{:<10s} rs1:{:<10s} rs2:{:<10s} imm:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))

def transform_one_ins(one_ins):
  bitwise = []
  load = ['lb','lh','lw','lbu','lhu']
  store = ['sb','sh','sw']
  imm = ['addi','slti','sltiu','xori','ori','andi', 'slli', 'srli', 'srai']
  reg = ['add','sub','sll','slt','sltu', 'xor', 'srl', 'sra', 'or', 'and']
  branch = ['beq','bne','blt','bge','bltu', 'bgeu']

  if len(one_ins) == 4 : 
    i = one_ins[0]
    rd = one_ins[1]
    rs1 = one_ins[2]
    rs2 = one_ins[3]

    #print('Ins:{:<15s} Part1:{:<10s} Part2:{:<10s} Part3:{:<10s}'.format(i,rd,rs1,rs2))
    #if i== 'lb' or i== 'lh' or i== 'lw' or i== 'lbu' or i== 'lhu' : 
    if i in load:
       bitwise = load_ins(i,rd,rs1,rs2) 
       __print_load__(bitwise)

    if i in store:
       bitwise = store_ins(i,rd,rs1,rs2)
       __print_store__(bitwise)

    if i in imm:
       bitwise = imm_ins(i,rd,rs1,rs2)
       __print_imm__(bitwise)

    if i in reg:
       bitwise = reg_ins(i,rd,rs1,rs2)
       __print_reg__(bitwise)

    if i in branch:
       bitwise = branch_ins(i,rd,rs1,rs2)
       __print_branch__(bitwise)

  return bitwise

def transform(ins):
  a = []
  for i in ins: 
    b = transform_one_ins(i)
    b = b[::-1]
    n = ''.join(b)
    a.append(n)
  return a
    
if __name__ == "__main__":
  
  f = open("add.s", "r");
  ins = []
  for line in f:
    if line not in ('\n','\r\n'): 
      a = line.replace("\n",'')
      tmp = a.split()[0]
      a = a.replace(tmp, '')
      if '(' not in a:
        a = a.replace(' ','')
        a = a.split(',')
        a.insert(0,tmp)
        ins.append(a)
      else : 
        a = a.replace(' ','')
        a = a.split(',')
        par = a[-1]
        a.pop()
        par = par.split('(')
        par[-1] = par[-1].replace(')','')
        a.insert(0,tmp)
        a.append(par[-1])
        a.append(par[-2])
        ins.append(a)
  b = transform(ins)
  for i,bin_ins in enumerate(b):
    print(f"result({i}) := \"{bin_ins}\";")

