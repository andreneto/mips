.data 
.text

addi $s0, $zero, 5
addi $s1, $zero, -6

bne $s0, $s1, next
addi $t0, $zero, -1
next:
addi $t0, $zero, 1
bne $s1, $s1, next2
addi $t1, $zero, -1
next2:
addi $t1, $zero , 1

