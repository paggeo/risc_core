# Custom Risc-v core 

A project to learn basics ideas of designing a chip from start. 
This is meant to be done first in C then in a hardare description language
(Vhdl or Verilog) and the to run on a FPGA.

## Basics ideas : 
- 32 bit processor that can handle demical, floating, vector operations
- out-of-order , 5-stage pipeline, basic memory system 

## Things to implement
- [x] Float Point Unit (Fpu) 
  - Has to do fadd, fmult,mmult(matrix multiplication) to 32 bit IEEE float
- [ ] ALU 
  - Has to do add, sub, and, or, not, xor, mul
- [ ] Base instruction set
- [ ] Pipeline
- [ ] Out-of-order with ROB
- [ ] Multiplication and Division (M extension)
- [ ] Atomic instructions (A extension)
  - As a start not multithread or multicore yet.
- [ ] Floationg point Signle-Precision (F extension)
- [ ] Vector Operators ( V extension) 


## Things to consider to implement (Not yet desiced) 
- DMA
- Transactional Memory

## Take from [Risc-V documentation](https://riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf)
