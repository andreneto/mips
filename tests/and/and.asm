.data 
.text

addi $s0, $zero, 5
addi $s1, $zero, 4
addi $s2, $zero, -6
addi $s4, $zero, 750
addi $s5, $zero, 230
and $t0, $s0, $s1 # 5$4
and $t1, $s0, $s2 #5&(-6)
and $t2, $s0, $s0 #5&5
and $t3, $s4, $s5 #750&230