.data 
.text

addi $s0, $zero, 5
addi $s1, $zero, -6
addi $s2, $zero, 750
addi $s3, $zero, 3
addi $s4, $zero, -15


slt $t0, $s0, $s3
slt $t1, $s1, $s2
slt $t2, $s1, $s0
slt $t3, $s4, $s1
slt $t4, $s0, $s0
