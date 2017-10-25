.data 
.text

addi $s0, $zero, 5
addi $s1, $zero, 4
addi $s2, $zero, -6
addi $s3, $zero, -3
addi $s4, $zero, 750
addi $s5, $zero, 230
sub $t0, $s0, $s1 #5-4
sub $t1, $s0, $s2 #5-(-6)
sub $t3, $s2, $s3 #-6-(-3)
sub $t4, $s4, $s5 #750-230