.section .text
.global main
main : 
  add  t0, zero, zero   # i = 0
  lw t1, 1(t0) # t1 <= 1
  addi  t1, t1, 2   # t1 <= 3
  sw t1, 1(t0) # store in memory 
