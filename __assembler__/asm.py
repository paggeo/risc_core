#!/usr/bin/env python3
import os 
import glob
from enum import Enum 
import struct

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

PC = 32

regfile = None
def reset(): 
	global regfile
	regfile = Regfile()

# def readfile(path):
def replace(arr,start,string):
	x = [int(a) for a in string]
	for i in range(start,start+ len(x)):
		arr[-(i+1)]=string[i-start]
	return arr
	 
def decode(instruction):
	ins = str(instruction).replace(',','').replace('\n','').replace('\t', '')
	ins = ins.split(' ')
	print(ins)
	arr = ['0'] *32
	if (ins[0] == 'lui' or ins[0] == 'auipc' ): ## U-type
	 print('U-type')
	elif (ins[0] == 'jal'):  ## J-type
	 print('J-type')
	elif (ins[0] == 'beq' or ins[0] == 'bne' or ins[0] == 'blt' or ins[0] == 'bge' or ins[0] == 'bltu' or ins[0] == 'bgeu'): ## B-type
	 print('B-type')
	elif (ins[0] == 'sb' or ins[0] == 'sh' or ins[0] == 'sw'): ## S-type 
	 print('S-type')
	elif (ins[0] == 'jalr' or ins[0] == 'lb' or ins[0] == 'lh' or ins[0] == 'lw' or ins[0] == 'lbu' or ins[0] == 'lhu' or ins[0] == 'addi' or ins[0] == 'slti' or ins[0] == 'sltiu' or ins[0] == 'xori' or ins[0] == 'ori' or ins[0] == 'andi'): ## I-type
	 print('I-type')
	elif (ins[0] == 'slli' or ins[0] == 'srli' or ins[0] == 'srai' or ins[0] == 'add' or ins[0] == 'sub' or ins[0] == 'sll' or ins[0] == 'slt' or ins[0] == 'sltu' or ins[0] == 'xor' or ins[0] == 'srl' or ins[0] == 'sra' or ins[0] == 'or' or ins[0] == 'and'): ## R-type
	 print('R-type') 
	

	arr = replace(arr, 28, '1111')
	return ''.join(str(e) for e in arr)
	 
if __name__ == '__main__' : 
	print(regnames)
	if not os.path.isdir('custom-isa-assembly'):
		os.mkdir('custom-isa-assembly')
	for x in glob.glob('custom-isa-tests/*'):
		if not x.endswith('.S'):
			continue
		g =	open('custom-isa-assembly/%s' % x.split('/')[-1], "w") 
		with open(x, 'r') as f: 
			count = 0 
			instructions = f.readlines()
			for instruction in instructions: 
				count += 1
				byte_instruction = decode(instruction)
				print(byte_instruction)
				#g.write(byte_instruction)	
			print(f'#lines: \t{count}')

