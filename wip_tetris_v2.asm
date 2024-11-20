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
#---------------------------------------------------------------------------------
# register usage :
#	$s0 --> block type #
#	$s1-$s4 --> mem. addresses of block pixels
#	$s5 --> block position #
#	$s6 --> block color hex
#	$s7 --> background color hex
#	$t regs --> balling
#---------------------------------------------------------------------------------
lw $s7, background	# $s7 = background hex
jal func_draw_rand	# call func_draw_rand
j game_loop
#---------------------------------------------------------------------------------
func_draw_rand:		# draws a random block at the top of the screen
ori $v0, $0, 42
ori $a1, $0, 0xFFFF
syscall			# puts some random stuff in $a0 for Extra Randomess idfk
ori $v0, $0, 42
ori $a1, $0, 7
syscall			# sets $a0 to random number from 0-6 inclusive

or $s0, $0, $a0		# block type = $s0 = $a0
and $s5, $s5, $0  	# position = $s5 = 0

ori $t0, $0, 6	# set comparison values
ori $t1, $0, 5
ori $t2, $0, 4
ori $t3, $0, 3
ori $t4, $0, 2
ori $t5, $0, 1
beq $a0, $t0, block_T	# if $a0 = 6 then draw block T
beq $a0, $t1, block_Z	# if $a0 = 5 then draw block Z
beq $a0, $t2, block_S	# if $a0 = 4 then draw block S
beq $a0, $t3, block_J	# if $a0 = 3 then draw block J
beq $a0, $t4, block_L	# if $a0 = 2 then draw block L
beq $a0, $t5, block_I	# if $a0 = 1 then draw block I
# otherwise, draw block O
# there should technically be a nop here to prevent lw $s6, yellow from executing preemptively
# ----------------------------------------
block_O:
lw $s6, yellow		# load color
ori $s1, $0, 0x1001001C	# addr of px1
ori $s2, $0, 0x10010020	# addr of px2
addi $s3, $s1, -64	# addr of px3 offset from px1
addi $s4, $s2, -64	# addr of px4 offset from px2
j end_draw_rand
# ----------------------------------------
block_I:
lw $s6, blue		# load color
ori $s1, $0, 0x10010020	# addr of px1
ori $s2, $0, 0x1001001C	# addr of px2
ori $s3, $0, 0x10010018	# ...
ori $s4, $0, 0x10010024
j end_draw_rand
# ----------------------------------------
block_L:
lw $s6, indigo
ori $s1, $0, 0x10010020
ori $s2, $0, 0x1001001C
ori $s3, $0, 0x10010024
addi $s4, $s2, -64
j end_draw_rand
# ----------------------------------------
block_J:
lw $s6, orange
ori $s1, $0, 0x10010020
ori $s2, $0, 0x1001001C
ori $s3, $0, 0x10010024
addi $s4, $s3, -64
j end_draw_rand
# ----------------------------------------
block_S:
lw $s6, green
ori $s1, $0, 0x1000FFE0	# px4 - 64
ori $s2, $0, 0x1000FFE4	# px1 + 4
ori $s3, $0, 0x1001001C
ori $s4, $0, 0x10010020
j end_draw_rand
# ----------------------------------------
block_Z:
lw $s6, red
ori $s1, $0, 0x1000FFDC # px2 - 64
ori $s2, $0, 0x1001001C
ori $s3, $0, 0x1000FFD8	# px1 - 4
ori $s4, $0, 0x10010020
j end_draw_rand
# ----------------------------------------
block_T:
lw $s6, violet
ori $s1, $0, 0x1000FFE0	# px2 - 64
ori $s2, $0, 0x10010020
ori $s3, $0, 0x1001001C
ori $s4, $0, 0x10010024
j end_draw_rand
# ----------------------------------------
end_draw_rand:
sw $s6, 0($s1)
sw $s6, 0($s2)
sw $s6, 0($s3)
sw $s6, 0($s4)
jr $ra
#---------------------------------------------------------------------------------
func_rotate_block:	# rotates blocks given block type ($s0) and position ($s5)
ori $t0, $0, 6	# set comparison values
ori $t1, $0, 5
ori $t2, $0, 4
ori $t3, $0, 3
ori $t4, $0, 2
ori $t5, $0, 1
beq $s0, $t0, rotate_T	# branch
beq $s0, $t1, rotate_S_or_Z
beq $s0, $t2, rotate_S_or_Z
beq $s0, $t3, rotate_J_or_L
beq $s0, $t4, rotate_J_or_L
beq $s0, $t5, rotate_I
# nop
jr $ra			# otherwise end function
# ----------------------------------------
rotate_T:
ori $t3, $0, 3	# set comparison valuess
ori $t2, $0, 2
ori $t1, $0, 1
beq $s5, $t3, T_pos_3	# branch
beq $s5, $t2, T_pos_2
beq $s5, $t1, T_pos_1
# nop
T_pos_0:
sw $s7, 0($s3)		# erase previous px3
sw $s7, 0($s4)		# erase previous px4
addi $s3, $s3, -124	# calculate new px3
addi $s4, $s4, -64	# calculate new px4
sw $s6, 0($s3)		# draw new px3
sw $s6, 0($s4)		# draw new px4
j end_rotate_block

T_pos_1:
sw $s7, 0($s3)		# erase previous px3
addi $s3, $s3, 60	# calculate new px3
sw $s6, 0($s3)		# draw new px3
j end_rotate_block

T_pos_2:
sw $s7, 0($s4)		# erase previous px4
addi $s4, $s4, -68	# calculate new px4
sw $s6, 0($s4)		# draw new px4
j end_rotate_block

T_pos_3:
sw $s7, 0($s3)		# erase previous px3
sw $s7, 0($s4)		# erase previous px4
addi $s3, $s3, 64	# calculate new px3
addi $s4, $s4, 132	# calculate new px4
sw $s6, 0($s3)		# draw new px3
sw $s6, 0($s4)		# draw new px4
j end_rotate_block
# ----------------------------------------
rotate_S_or_Z:
ori $t0, $0, 8		# set base offsets
ori $t1, $0, -128

addi $sp, $sp, -4	# make space for $ra on the stack
sw $ra 0($sp)		# push $ra onto the stack
jal func_neg1_to_power_of_pos # call func $v0 = (-1)^pos
lw $ra 0($sp)		# pop $ra from the stack
addi $sp, $sp, 4	# readjust stack pointer

sw $s7, 0($s3)		# erase previous px3
sw $s7, 0($s4)		# erase previous px4

# calculate new px3
mult $t0, $v0		# lo = 8 * (-1)^pos
mflo $t0		# $t0 = 8 * (-1)^pos
add $s3, $s3, $t0	# px3 = px3 + calculated offset $t0

# calculate new px4
mult $t1, $v0		# lo = -128 * (-1)^pos
mflo $t1		# $t1 = -128 * (-1)^pos
add $s4, $s4, $t1	# px4 = px4 + calculated offset $t1

sw $s6, 0($s3)		# draw new px3
sw $s6, 0($s4)		# draw new px4
j end_rotate_block
# ----------------------------------------
rotate_J_or_L:
sw $s7, 0($s2)		# erase previous px2
sw $s7, 0($s3)		# erase previous px3
sw $s7, 0($s4)		# erase previous px4

ori $t3, $0, 3		# $t0 = 3
ori $t2, $0, 2		# $t0 = 2
ori $t1, $0, 1		# $t0 = 1
beq $s5, $t3, J_or_L_pos_3
beq $s5, $t2, J_or_L_pos_2
beq $s5, $t1, J_or_L_pos_1
#nop
J_or_L_pos_0:
addi $s2, $s2, -60	# calculate new px2
addi $s3, $s3, 60	# calculate new px3
# if block type = 3 = J then jump to next L_px4
addi $t0, $s0, -3
beq $t0, $0, L_px4_pos_1
# else, calculate L_px4 for the current position
L_px4_pos_0:
addi $s4, $s4, 8	# calculate L's px4
j end_rotate_block

J_or_L_pos_1:
addi $s2, $s2, 68	# calculate new px2
addi $s3, $s3, -68	# calculate new px3
# if block type = 3 = J then jump to next L_px4
addi $t0, $s0, -3
beq $t0, $0, L_px4_pos_2
# else, calculate L_px4 for the current position
L_px4_pos_1:
addi $s4, $s4, 128	# calculate L's px4
j end_rotate_block

J_or_L_pos_2:
addi $s2, $s2, 60	# calculate new px2
addi $s3, $s3, -60	# calculate new px3
addi $t0, $s0, -3
beq $t0, $0, L_px4_pos_3
L_px4_pos_2:
addi $s4, $s4, -8	# calculate L's px4
j end_rotate_block

J_or_L_pos_3:
addi $s2, $s2, -68	# calculate new px2
addi $s3, $s3, 68	# calculate new px3
addi $t0, $s0, -3
beq $t0, $0, L_px4_pos_0
L_px4_pos_3:
addi $s4, $s4, -128	# calculate L's px4
j end_rotate_block

sw $s6, 0($s2)		# draw new px2
sw $s6, 0($s3)		# draw new px3
sw $s6, 0($s4)		# draw new px4
j end_rotate_block
# ----------------------------------------
rotate_I:
ori $t0, $0, -60	# px2 offset
ori $t1, $0, -120	# px3 offset
ori $t2, $0, -196	# px4 offset

addi $sp, $sp, -4	# make space for $ra on the stack
sw $ra 0($sp)		# push $ra onto the stack
jal func_neg1_to_power_of_pos # call func $v0 = (-1)^pos
lw $ra 0($sp)		# pop $ra from the stack
addi $sp, $sp, 4	# readjust stack pointer

sw $s7, 0($s2)		# erase previous px2
# calculate new px2
mult $t0, $v0		# lo = -60 * (-1)^pos
mflo $t0		# $t0 = -60 * (-1)^pos
add $s2, $s2, $t0	# px2 = px2 + calculated offset $t0

sw $s7, 0($s3)		# erase previous px3
# calculate new px3
mult $t1, $v0		# lo = -120 * (-1)^pos
mflo $t1		# $t1 = -120 * (-1)^pos
add $s3, $s3, $t1	# px3 = px3 + calculated offset $t1

sw $s7, 0($s4)		# erase previous px4
# calculate new px4
mult $t2, $v0		# lo = -196 * (-1)^pos
mflo $t2		# $t2 = -196 * (-1)^pos
add $s4, $s4, $t2	# px4 = px4 + calculated offset $t2

sw $s6, 0($s2)		# draw new px2
sw $s6, 0($s3)		# draw new px3
sw $s6, 0($s4)		# draw new px4
# ----------------------------------------
end_rotate_block:
ori $t0, $0, 4		# $t0 = 4
addi $s5, $s5, 1	# $s5 = $s5 + 1
div $s5, $t0
mfhi $s5		# $s5 = ($s5 + 1) mod 4
jr $ra
#---------------------------------------------------------------------------------
func_neg1_to_power_of_pos: # $v0 = (-1)^pos
# uses $v0, $v1, $a0, $a1 which don't need to be retained after $v0 is used
ori $v0, $0, 1		# return value
ori $v1, $0, -1		# will stay constant in loop but can be overwritten after
and $a0, $a0, $0	# i = $a0 = 0
loop_calculate:
# for (int i = 0, i < pos, i++)
slt $a1, $a0, $s5	# if $a0 < $s5 (i < pos) then $a1 = 1, else $a1 = 0
beq $a1, $0, end_func_neg1_to_power_of_pos
mult $v0, $v1		# lo = $v0 * $v1 = $v0 * -1
mflo $v0		# $v0 = $v0 * -1
addi $a0, $a0, 1	# increment i
j loop_calculate
end_func_neg1_to_power_of_pos:
jr $ra
#---------------------------------------------------------------------------------
game_loop:
ori $t0, $0, 64
lw $t1, 0xFFFF0004  	# key addr

ori $t2, $0, 119    	# $t2 = 119 (ASCII value for 'w')
ori $t3, $0, 97    	# $t2 = 97 (ASCII value for 'a')
ori $t4, $0, 115    	# $t2 = 115 (ASCII value for 's')
ori $t5, $0, 100    	# $t2 = 100 (ASCII value for 'd')
ori $t6, $0, 113   	# $t2 = 113 (ASCII value for 'q')

beq $t1, $t2, call_func_rotate
beq $t1, $t3, move_left
beq $t1, $t4, move_down
beq $t1, $t5, move_right
beq $t1, $t6, quit
# nop
j cont			# if nothing pressed

move_left:
ori $t0, $0, 60
j cont
move_right:
ori $t0, $0, 68
j cont
move_down:
ori $t0, $0, 128
j cont

call_func_rotate:
jal func_rotate_block
ori $t0, $0, 64		# offset value for block drop

cont:
ori $t1, $0, 0		# reset key value
sw $t1, 0xFFFF0004
# move down 1px
sw $s7, 0($s1)		# fill in prev pixels with bg color
sw $s7, 0($s2)
sw $s7, 0($s3)
sw $s7, 0($s4)
add $s1, $s1, $t0	# offset
add $s2, $s2, $t0
add $s3, $s3, $t0
add $s4, $s4, $t0
sw $s6, 0($s1)		# fill in new pixels with block color
sw $s6, 0($s2)
sw $s6, 0($s3)
sw $s6, 0($s4)

# buffer
ori $v0, $0, 32
ori $a0, $0, 500
syscall

j game_loop
#---------------------------------------------------------------------------------
quit:
