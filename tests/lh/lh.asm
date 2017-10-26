.data 
a: .word 2
.text


addi $t0, $zero, 1
lh $t1, a($zero)
addi $t0, $zero, -1