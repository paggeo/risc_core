#!/usr/bin/env python3

from constructors import *
import helper as hp

def transform_one_ins(one_ins):
  bitwise = []
  load = ['lb','lh','lw','lbu','lhu']
  store = ['sb','sh','sw']
  imm = ['addi','slti','sltiu','xori','ori','andi', 'slli', 'srli', 'srai']
  reg = ['add','sub','sll','slt','sltu', 'xor', 'srl', 'sra', 'or', 'and']
  branch = ['beq','bne','blt','bge','bltu', 'bgeu']
  jal = ['jal']
  jalr = ['jalr']
  auipc = ['auipc']
  lui = ['lui']

  if len(one_ins) == 4 : 
    i = one_ins[0]
    rd = one_ins[1]
    rs1 = one_ins[2]
    rs2 = one_ins[3]

    if i in load:
      bitwise = load_ins(i,rd,rs1,rs2) 
      hp.__print_load__(bitwise)

    if i in store:
      bitwise = store_ins(i,rd,rs1,rs2)
      hp.__print_store__(bitwise)

    if i in imm:
      bitwise = imm_ins(i,rd,rs1,rs2)
      hp.__print_imm__(bitwise)

    if i in reg:
      bitwise = reg_ins(i,rd,rs1,rs2)
      hp.__print_reg__(bitwise)

    if i in branch:
      bitwise = branch_ins(i,rd,rs1,rs2)
      hp.__print_branch__(bitwise)
    
    if i in jalr:
      bitwise = jalr_ins(i,rd,rs1,rs2)
      hp.__print_jalr__(bitwise)

  if len(one_ins) == 3:
    if one_ins[0] in jal:
      bitwise = jal_ins(one_ins[0],one_ins[1],one_ins[2])
      hp.__print_jal__(bitwise)


    if one_ins[0] in lui: 
      bitwise = lui_ins(one_ins[0],one_ins[1],one_ins[2])
      hp.__print_lui__(bitwise)

    if one_ins[0] in auipc: 
      bitwise = auipc_ins(one_ins[0],one_ins[1],one_ins[2])
      hp.__print_auipc__(bitwise)


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