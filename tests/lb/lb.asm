.data 
a: .word 2
.text


addi $t0, $zero, 1
lb $t0, a($zero)
addi $t0, $zero, -1
