#!/usr/bin/env python3


def bindigits(n, bits):
  s = bin(n & int("1"*bits, 2))[2:]
  return ("{0:0>%s}" % (bits)).format(s)

def transform_one_ins(one_ins):
  bitwise = []
  if len(one_ins) == 4 : 
    i = one_ins[0]
    rd = one_ins[1]
    rs1 = one_ins[2]
    rs2 = one_ins[3]

    print('Instruction:{:<15s} Rd:{:<10s} Rs1:{:<10s} Rs2:{:<10s}'.format(i,rd,rs1,rs2))
    if i== 'lb' or i== 'lh' or i== 'lw' or i== 'lbu' or i== 'lhu' : 
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
       print('Byte Instruction:{:<10s} Rd:{:<10s} funct3:{:<10s} Rs1:{:<10s} Rs2:{:<10s}'.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4]))
    if i== 'sb' or i== 'sh' or i== 'sw':
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

       print('Byte Instruction:{:<10s} Rd:{:<10s} funct3:{:<10s} Rs1:{:<10s} Rs2:{:<10s}, Rs3:{:<10s}'.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))

    if i== 'addi' or i== 'slti' or i== 'sltiu' or i== 'xori' or i== 'ori' or i == 'andi' or i == 'slli' or i == 'srli' or i == 'srai':
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

       if i == 'slli' or i == 'srli' or i == 'srai' :
        print('Byte Instruction:{:<10s} Rd:{:<10s} funct3:{:<10s} Rs1:{:<10s} Rs2:{:<10s}, Rs3:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))
       else:
        print('Byte Instruction:{:<10s} Rd:{:<10s} funct3:{:<10s} Rs1:{:<10s} Rs2:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4]))

    if i== 'add' or i == 'sub' or i == 'sll' or i== 'slt' or i== 'sltu' or i== 'xor' or i == 'srl' or i == 'sra' or i == 'or' or i == 'and':
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

       print('Byte Instruction:{:<10s} Rd:{:<10s} funct3:{:<10s} Rs1:{:<10s} Rs2:{:<10s}, Rs3:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))

    if i == 'beq' or i == 'bne' or i == 'blt' or i == 'bge' or i == 'bltu' or i == 'bgeu' : 
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
       print('Byte Instruction:{:<10s} Rd:{:<10s} funct3:{:<10s} Rs1:{:<10s} Rs2:{:<10s}, Rs3:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2], bitwise[3], bitwise[4], bitwise[5]))

  return bitwise

def transform(ins):
  a = []
  for i in ins: 
    b = transform_one_ins(i)
    b = b[::-1]
    n = '_'.join(b)
    a.append(n)
  return a
    
if __name__ == "__main__":
  
  f = open("add.s", "r");
  ins = []
  for line in f:
    a = line.replace("\n",'')
    a = a.replace(' ','')
    a = a.split(',')
    ins.append(a)
  b = transform(ins)
  for i in b:
    print(i)
  #for i in ins:
  #  b = transform_one_ins(i)
  #  b = b[::-1]
  #  n = '_'.join(b)
  #  print(f"Insruction in bits :{n}")


