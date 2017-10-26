.data 
a: .word 2
.text

addi $t0, $zero, 1
addi $t1, $zero, 5
sw $t1, a($zero)
addi $t0, $zero, -1