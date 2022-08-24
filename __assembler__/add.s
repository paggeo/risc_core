lw   x1, 1(x0) 
lw   x2, 10(x0) 
add x3, x1,x2
sub x4, x1, x2
addi x5, x5, -2
sw x3 , 3(x0)

jal x2, -12
jalr x12, 12(x1)
lui x2, 12
auipc x2,-12
