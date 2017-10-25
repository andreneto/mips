.data 
.text

addi $s0, $zero, 5
addi $s1, $zero, 4
addi $s2, $zero, -6
addi $s3, $zero, -3
addi $s5, $zero, 780
addi $s6, $zero, 150

div $s0, $s1 #5/4
mfhi $t0
mflo $t1


div $s2, $s3 #-6/-3
mfhi $t0
mflo $t1


div $s1, $s1 #4/4
mfhi $t0
mflo $t1


div $s5, $s6 #780/150
mfhi $t0
mflo $t1