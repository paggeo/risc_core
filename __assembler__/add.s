add  x5, x0, x0
lw   x1, x0, 1 
lw   x1, x0, -10 
addi  x1, x1, 2
sw x1, x0, 1
sw x1, x0, -11
add x3, x4, x5
sub x3,x4, x5
beq x1, x2, -3

lw x5, -13(x1)
sw x2, -123(x2)
