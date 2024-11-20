# this code might be scuffed but its okay it works
.data
background:	.word 0x00000000
red:		.word 0x00F00001
orange:		.word 0x00F0A001
yellow:		.word 0x00F0F001
green:		.word 0x0000F001
blue:		.word 0x0000F0F1
indigo:		.word 0x000000F1
violet:		.word 0x00A000F1

.text
func_draw_rand:		# draws a random block at the top of the screen
ori $v0, $zero, 42
ori $a1, $zero, 0xFFFF
syscall			# puts some random stuff in $a0 for Extra Randomess idfk

ori $v0, $zero, 42
ori $a1, $zero, 7
syscall			# $a0 = random number from 0-6 inclusive

# ori $a0, $zero, 4	# FOR TESTING ---- REMOVE LATER

addi $a1, $a1, -1	# $a1 = 6
beq $a0, $a1, block_T	# if generated num $a0 = 6 then draw block T
addi $a1, $a1, -1	# $a1 = 5
beq $a0, $a1, block_Z	# if generated num $a0 = 5 then draw block Z
addi $a1, $a1, -1	# $a1 = 4
beq $a0, $a1, block_S	# if generated num $a0 = 4 then draw block S
addi $a1, $a1, -1	# $a1 = 3
beq $a0, $a1, block_J	# if generated num $a0 = 3 then draw block J
addi $a1, $a1, -1	# $a1 = 2
beq $a0, $a1, block_L	# if generated num $a0 = 2 then draw block L
addi $a1, $a1, -1	# $a1 = 1
beq $a0, $a1, block_I	# if generated num $a0 = 1 then draw block I
# otherwise, draw block O

block_O:
lw $s5, yellow		# load color
ori $s1, $0, 0x1001001C	# addr of px1
sw $s5, 0($s1)
ori $s2, $0, 0x10010020	# addr of px2
sw $s5, 0($s2)
addi $s3, $s1, -64	# addr of px3 offset from px1
sw $s5, 0($s3)
addi $s4, $s2, -64	# addr of px4 offset from px2
sw $s5, 0($s4)
j end_draw_rand

block_I:
lw $s5, blue		# load color
ori $s1, $0, 0x10010020	# addr of px1
sw $s5, 0($s1)
ori $s2, $0, 0x1001001C	# addr of px2
sw $s5, 0($s2)
ori $s3, $0, 0x10010018	# ...
sw $s5, 0($s3)
ori $s4, $0, 0x10010024
sw $s5, 0($s4)
j end_draw_rand

block_L:
lw $s5, indigo
ori $s1, $0, 0x10010020
sw $s5, 0($s1)
ori $s2, $0, 0x1001001C
sw $s5, 0($s2)
ori $s3, $0, 0x10010024
sw $s5, 0($s3)
addi $s4, $s2, -64
sw $s5, 0($s4)
j end_draw_rand

block_J:
lw $s5, orange
ori $s1, $0, 0x10010020
sw $s5, 0($s1)
ori $s2, $0, 0x1001001C
sw $s5, 0($s2)
ori $s3, $0, 0x10010024
sw $s5, 0($s3)
addi $s4, $s3, -64
sw $s5, 0($s4)
j end_draw_rand

block_S:
lw $s5, green
ori $s1, $0, 0x1000FFE0	# px4 - 64
sw $s5, 0($s1)
ori $s2, $0, 0x1000FFE4	# px1 + 4
sw $s5, 0($s2)
ori $s3, $0, 0x1001001C
sw $s5, 0($s3)
ori $s4, $0, 0x10010020
sw $s5, 0($s4)
j end_draw_rand

block_Z:
lw $s5, red
ori $s1, $0, 0x1000FFDC # px2 - 64
sw $s5, 0($s1)
ori $s2, $0, 0x1001001C
sw $s5, 0($s2)
ori $s3, $0, 0x1000FFD8	# px1 - 4
sw $s5, 0($s3)
ori $s4, $0, 0x10010020
sw $s5, 0($s4)
j end_draw_rand

block_T:
lw $s5, violet
ori $s1, $0, 0x1000FFE0	# px2 - 64
sw $s5, 0($s1)
ori $s2, $0, 0x10010020
sw $s5, 0($s2)
ori $s3, $0, 0x1001001C
sw $s5, 0($s3)
ori $s4, $0, 0x10010024
sw $s5, 0($s4)
j end_draw_rand

end_draw_rand:
or $s6, $0, $a0		# block type = $s6 = $a0
and $s7, $s7, $0  	# position = $s7 = 0
j game_loop

func_rotate_block:	# rotates blocks
# value w/ block type = $s6
# value w/ position = $s7

ori $t0, $0, 6		# $t0 = 6
beq $s6, $t0, rotate_T
addi $t0, $t0, -1	# $t0 = 5
beq $s6, $t0, rotate_S_or_Z
addi $t0, $t0, -1	# $t0 = 4
beq $s6, $t0, rotate_S_or_Z
addi $t0, $t0, -1	# $t0 = 3
beq $s6, $t0, rotate_J_or_L
addi $t0, $t0, -1	# $t0 = 2
beq $s6, $t0, rotate_J_or_L
addi $t0, $t0, -1	# $t0 = 1
beq $s6, $t0, rotate_I
j end_rotate_block	# otherwise end function


rotate_T:
ori $t0, $0, 3		# $t0 = 3
beq $s7, $t0, T_pos_3
addi $t0, $t0, -1	# $t0 = 2
beq $s7, $t0, T_pos_2
addi $t0, $t0, -1	# $t0 = 1
beq $s7, $t0, T_pos_1
addi $t0, $t0, -1	# $t0 = 0
beq $s7, $t0, T_pos_0

T_pos_0:
sw $s0, 0($s3)		# erase previous px3
sw $s0, 0($s4)		# erase previous px4

addi $s3, $s3, -124	# calculate new px3
addi $s4, $s4, -64	# calculate new px4

sw $s5, 0($s3)		# draw new px3
sw $s5, 0($s4)		# draw new px4
j end_rotate_block

T_pos_1:
sw $s0, 0($s3)		# erase previous px3
addi $s3, $s3, 60	# calculate new px3
sw $s5, 0($s3)		# draw new px3
j end_rotate_block

T_pos_2:
sw $s0, 0($s4)		# erase previous px4
addi $s4, $s4, -68	# calculate new px4
sw $s5, 0($s4)		# draw new px4
j end_rotate_block

T_pos_3:
sw $s0, 0($s3)		# erase previous px3
sw $s0, 0($s4)		# erase previous px4

addi $s3, $s3, 64	# calculate new px3
addi $s4, $s4, 132	# calculate new px4

sw $s5, 0($s3)		# draw new px3
sw $s5, 0($s4)		# draw new px4
j end_rotate_block


rotate_S_or_Z:
ori $t0, $0, 8
ori $t1, $0, -128

jal func_neg1_to_power_of_pos # $v0 = (-1)^pos

sw $s0, 0($s3)		# erase previous px3
# calculate new px3
mult $t0, $v0		# lo = 8 * (-1)^pos
mflo $t0		# $t0 = 8 * (-1)^pos
add $s3, $s3, $t0	# px3 = px3 + calculated offset $t0

sw $s0, 0($s4)		# erase previous px4
# calculate new px4
mult $t1, $v0		# lo = -128 * (-1)^pos
mflo $t1		# $t1 = -128 * (-1)^pos
add $s4, $s4, $t1	# px4 = px4 + calculated offset $t1

sw $s5, 0($s3)		# draw new px3
sw $s5, 0($s4)		# draw new px4
j end_rotate_block


rotate_J_or_L:
sw $s0, 0($s2)		# erase previous px2
sw $s0, 0($s3)		# erase previous px3
sw $s0, 0($s4)		# erase previous px4

ori $t0, $0, 3		# $t0 = 3
beq $s7, $t0, JL_pos3_px2px3
addi $t0, $t0, -1	# $t0 = 2
beq $s7, $t0, JL_pos2_px2px3
addi $t0, $t0, -1	# $t0 = 1
beq $s7, $t0, JL_pos1_px2px3
addi $t0, $t0, -1	# $t0 = 0
beq $s7, $t0, JL_pos0_px2px3

JL_pos0_px2px3:
addi $s2, $s2, -60	# calculate new px2
addi $s3, $s3, 60	# calculate new px3
j JL_pos0_px4

JL_pos1_px2px3:
addi $s2, $s2, 68	# calculate new px2
addi $s3, $s3, -68	# calculate new px3
j JL_pos1_px4

JL_pos2_px2px3:
addi $s2, $s2, 60	# calculate new px2
addi $s3, $s3, -60	# calculate new px3
j JL_pos2_px4

JL_pos3_px2px3:
addi $s2, $s2, -68	# calculate new px2
addi $s3, $s3, 68	# calculate new px3
j JL_pos3_px4

JL_pos0_px4:
# if ($s6 = ($t0 = 2)) then {px4 += 8} else {px4 += 128}
ori $t0, $0, 2		# $t0 = 2
bne $s6, $t0, J_pos0_px4
addi $s4, $s4, 8
j JL_cont
J_pos0_px4:
addi $s4, $s4, 128
j JL_cont

JL_pos1_px4:
# if ($s6 = ($t0 = 2)) then {px4 += 128} else {px4 += -8}
ori $t0, $0, 2		# $t0 = 2
bne $s6, $t0, J_pos1_px4
addi $s4, $s4, 128
j JL_cont
J_pos1_px4:
addi $s4, $s4, -8
j JL_cont

JL_pos2_px4:
# if ($s6 = ($t0 = 2)) then {px4 += -8} else {px4 += -128}
ori $t0, $0, 2		# $t0 = 2
bne $s6, $t0, J_pos2_px4
addi $s4, $s4, -8
j JL_cont
J_pos2_px4:
addi $s4, $s4, -128
j JL_cont

JL_pos3_px4:
# if ($s6 = ($t0 = 2)) then {px4 += -128} else {px4 += 8}
ori $t0, $0, 2		# $t0 = 2
bne $s6, $t0, J_pos3_px4
addi $s4, $s4, -128
j JL_cont
J_pos3_px4:
addi $s4, $s4, 8
j JL_cont

JL_cont:
sw $s5, 0($s2)		# draw new px2
sw $s5, 0($s3)		# draw new px3
sw $s5, 0($s4)		# draw new px4
j end_rotate_block


rotate_I:
ori $t0, $0, -60	# px2 offset
ori $t1, $0, -120	# px3 offset
ori $t2, $0, -196	# px4 offset

jal func_neg1_to_power_of_pos # $v0 = (-1)^pos

sw $s0, 0($s2)		# erase previous px2
# calculate new px2
mult $t0, $v0		# lo = -60 * (-1)^pos
mflo $t0		# $t0 = -60 * (-1)^pos
add $s2, $s2, $t0	# px2 = px2 + calculated offset $t0

sw $s0, 0($s3)		# erase previous px3
# calculate new px3
mult $t1, $v0		# lo = -120 * (-1)^pos
mflo $t1		# $t1 = -120 * (-1)^pos
add $s3, $s3, $t1	# px3 = px3 + calculated offset $t1

sw $s0, 0($s4)		# erase previous px4
# calculate new px4
mult $t2, $v0		# lo = -196 * (-1)^pos
mflo $t2		# $t2 = -196 * (-1)^pos
add $s4, $s4, $t2	# px4 = px4 + calculated offset $t2

sw $s5, 0($s2)		# draw new px2
sw $s5, 0($s3)		# draw new px3
sw $s5, 0($s4)		# draw new px4
j end_rotate_block


end_rotate_block:
# update $s7 = pos value
addi $t0, $s7, 1	# worlds worst register usage
ori $t1, $0, 4
slt $t2, $t0, $t1	# if ($s7 (pos) + 1) < 4 then $t2 = 1 else $t2 = 0
beq $t2, $0, pos_back_to_0
addi $s7, $s7, 1
j cont_from_rotation
pos_back_to_0:
and $s7, $s7, $0
j cont_from_rotation


func_neg1_to_power_of_pos: # $v0 = (-1)^pos
# uses $v0, $v1, $a0, $a1 which don't need to be retained after $v0 is used
ori $v0, $0, 1		# return value
ori $v1, $0, -1		# will stay constant in loop but can be overwritten after
and $a0, $a0, $0	# i = $a0 = 0
loop_calculate:
# for (int i = 0, i < pos, i++)
slt $a1, $a0, $s7	# if $a0 < $s7 (i < pos) then $a1 = 1, else $a1 = 0
beq $a1, $0, end_func_neg1_to_power_of_pos
mult $v0, $v1		# lo = $v0 * $v1 = $v0 * -1
mflo $v0		# $t2 = $t2 * -1
addi $a0, $a0, 1	# increment i
j loop_calculate
end_func_neg1_to_power_of_pos:
jr $ra


game_loop:
and $s0, $s0, $0
ori $t0, $0, 64
lw $t1, 0xFFFF0004  	# key value

ori $t2, $t0, 97    	# $t2 = 97 (ASCII value for 'a')
beq $t1, $t2, move_left
addi $t2, $t2, 3    	# $t2 = 100 (ASCII value for 'd')
beq $t1, $t2, move_right
addi $t2, $t2, 13   	# $t2 = 113 (ASCII value for 'q')
beq $t1, $t2, quit
addi $t2, $t2, 2    	# $t2 = 115 (ASCII value for 's')
beq $t1, $t2, move_down
addi $t2, $t2, 4    	# $t2 = 119 (ASCII value for 'w')
beq $t1, $t2, func_rotate_block	# no jal func we ball
j cont

move_left:
ori $t0, $0, 60
j cont

move_right:
ori $t0, $0, 68
j cont

move_down:
ori $t0, $0, 128
j cont

cont_from_rotation:
ori $t0, $0, 64		# offset value for block drop
# buffer
ori $v0, $0, 32
ori $a0, $0, 200
syscall

cont:
ori $t1, $0, 0		# reset key value
sw $t1, 0xFFFF0004

# move down 1px
sw $s0, 0($s1)		# fill in prev pixels with bg color
add $s1, $s1, $t0
sw $s0, 0($s2)
add $s2, $s2, $t0
sw $s0, 0($s3)
add $s3, $s3, $t0
sw $s0, 0($s4)
add $s4, $s4, $t0

sw $s5, 0($s1)		# fill in new pixels with block color
sw $s5, 0($s2)
sw $s5, 0($s3)
sw $s5, 0($s4)

# call function to check whether block should stop

# buffer
ori $v0, $0, 32
ori $a0, $0, 200
syscall

j game_loop

quit:
