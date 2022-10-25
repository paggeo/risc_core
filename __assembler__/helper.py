def bindigits(n, bits):
  s = bin(n & int("1"*bits, 2))[2:]
  return ("{0:0>%s}" % (bits)).format(s)

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

def __print_jal__(bitwise):
  print('Jal:\t Opcode:{:<10s} rd:{:<10s} imm:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2]))

def __print_lui__(bitwise):
  print('Lui:\t Opcode:{:<10s} rd:{:<10s} imm:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2]))

def __print_auipc__(bitwise):
  print('Auipc:\t Opcode:{:<10s} rd:{:<10s} imm:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2]))

def __print_jalr__(bitwise):
  print('Jalr:\t Opcode:{:<10s} rd:{:<10s} funct3:{:<10s} rs1:{:<10s} imm:{:<10s} '.format(bitwise[0],bitwise[1],bitwise[2],bitwise[3],bitwise[4]))