.data 
a: .word 2
.text

addi $t0, $zero, 1
sh $s0, a(0)
addi $t0, $zero, -1