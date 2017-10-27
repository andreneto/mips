.data 
a: .word 5
.text

addi $s0, $zero, a
addi $s1, $zero, -6
addi $s2, $zero, 5

beqm $s0,$s1, pula
addi $t0, $zero, -1
pula:
addi $t0, $zero, 1

beqm $s0,$s2, pula2
addi $t1, $zero, -1
pula2:
addi $t1, $zero, 1

