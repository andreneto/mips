.data 
.text

addi $s0, $zero, 7
addi $s1, $zero, -2
addi $s2, $zero, 835
addi $s3, $zero, 1174
addi $s4, $zero, 7

ble  $s1, $s0, pula
addi $t0, $zero, -1
pula:
addi $t0, $zero, 1
ble $s3,$s2, pula3
addi $t1, $zero, -1
pula3:
addi $t1, $zero, 1
