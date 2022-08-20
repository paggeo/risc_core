add   a4, ra, sp
addi  a4, ra, 1
and   a4, ra, sp
andi  a4, ra, 1807
auipc a0, 0x2
beq   ra, sp, 0x80000230
bge   ra, sp, 0x800001f4
bgeu  ra, sp, 0x800001d4
blt   ra, sp, 0x80000214 
bltu  ra, sp, 0x800001f4
bne   ra, sp, 0x800001f4
jal   tp, 0x800001d4
jalr  t0, t1
lb    a4, 2(ra)
lbu   a4, 1(ra)
lh    a4, 0(ra)
lhu   a4, 2(ra)
lui   ra, 0xfffff
lw    a4, 8(ra)
or    a4, ra, sp
ori   a4, ra, 1807
sb    sp, 0(ra)
sh    sp, 2(ra)
sll   a4, ra, sp
slli  a4, ra, 0x1
slt   a4, ra, sp
slti  a4, ra, 0
sltiu a4, ra, 0
sltu  a4, ra, sp
sra   a4, ra, sp
srai  a4, ra, 0x0
srl   a4, ra, sp
srli  a4, ra, 0x7
sub   a4, ra, sp
sw    sp, 0(ra)
xor   a4, ra, sp
xori  a4, ra, 240
