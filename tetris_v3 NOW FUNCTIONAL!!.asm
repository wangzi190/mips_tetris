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
# draws a bound just off the bottom of the display
ori $t0, $0, 0x10010000
ori $t1, $0, 0x00000001
addi $t0, $t0, 2048

or $t2, $0, $t0
addi $t2, $t2, 64
draw_bound_loop:
beq $t0, $t2, start_game
sw $t1, 0($t0)
addi $t0, $t0, 4
j draw_bound_loop
#---------------------------------------------------------------------------------
start_game:
ori $s7, $0, 0x00000000	# $s7 = background hex
jal func_draw_rand	# call func_draw_rand
j game_loop
#---------------------------------------------------------------------------------
func_draw_rand:		# draws a random block at the top of the screen
ori $v0, $0, 42
ori $a1, $0, 7
syscall			# sets $a0 to random number from 0-6 inclusive

# ori $a0, $0, 5		# !!!!!!!!!! FOR TESTING ONLY !!!!!!!!!!

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
ori $s6, $0, 0x00f0f001	# load color (yellow)
ori $s1, $0, 0x1001001C	# addr of px1
ori $s2, $0, 0x10010020	# addr of px2
addi $s3, $s1, -64	# addr of px3 offset from px1
addi $s4, $s2, -64	# addr of px4 offset from px2
j end_draw_rand
# ----------------------------------------
block_I:
ori $s6, $0, 0x0000f0f1	# load color (blue)
ori $s1, $0, 0x10010020	# addr of px1
ori $s2, $0, 0x1001001C	# addr of px2
ori $s3, $0, 0x10010018	# ...
ori $s4, $0, 0x10010024
j end_draw_rand
# ----------------------------------------
block_L:
ori $s6, $0, 0x000000f1	# indigo
ori $s1, $0, 0x10010020
ori $s2, $0, 0x1001001C
ori $s3, $0, 0x10010024
addi $s4, $s2, -64
j end_draw_rand
# ----------------------------------------
block_J:
ori $s6, $0, 0x00f0a001	# orange
ori $s1, $0, 0x10010020
ori $s2, $0, 0x1001001C
ori $s3, $0, 0x10010024
addi $s4, $s3, -64
j end_draw_rand
# ----------------------------------------
block_S:
ori $s6, $0, 0x0000f001	# green
ori $s1, $0, 0x1000FFE0	# px4 - 64
ori $s2, $0, 0x1000FFE4	# px1 + 4
ori $s3, $0, 0x1001001C
ori $s4, $0, 0x10010020
j end_draw_rand
# ----------------------------------------
block_Z:
ori $s6, $0, 0x00f00001	# red
ori $s1, $0, 0x1000FFDC # px2 - 64
ori $s2, $0, 0x1001001C
ori $s3, $0, 0x1000FFD8	# px1 - 4
ori $s4, $0, 0x10010020
j end_draw_rand
# ----------------------------------------
block_T:
ori $s6, $0, 0x00a000f1	# violet
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
ori $t0, $0, 6		# set comparison values
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
ori $t3, $0, 3		# set comparison valuess
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

lw $t1, 0xffff0000	# $t1 = ready bit
beq $t1, $0, cont	# if ready bit == 0 then j cont

lw $t1, 0xffff0004  	# key addr

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
j cont			# if nothing or wrong key(s) pressed

move_left:
# check if at left edge
ori $t2, $0, 64		# $t2 = 64
div $s1, $t2
mfhi $t3
div $s2, $t2
mfhi $t4
div $s3, $t2
mfhi $t5
div $s4, $t2
mfhi $t6
beq $t3, $0, cont
beq $t4, $0, cont
beq $t5, $0, cont
beq $t6, $0, cont
# otherwise, load move_left offset
ori $t0, $0, 60
j cont
move_right:
# check if at right edge
ori $t2, $0, 60		# $t2 = 60
sub $t3, $s1, $t2
sub $t4, $s2, $t2
sub $t5, $s3, $t2
sub $t6, $s4, $t2
ori $t2, $0, 64		# $t2 = 64
div $t3, $t2
mfhi $t3
div $t4, $t2
mfhi $t4
div $t5, $t2
mfhi $t5
div $t6, $t2
mfhi $t6
beq $t3, $0, cont
beq $t4, $0, cont
beq $t5, $0, cont
beq $t6, $0, cont
# otherwise, load move_right offset
ori $t0, $0, 68
j cont
move_down:
ori $t0, $0, 128
j cont

call_func_rotate:
jal func_rotate_block
ori $t0, $0, 64		# offset value for block drop

cont:
# ----------------------------------------
jal check_obstructions	# call check_obstructions
ori $t7, $0, 1
bne $t0, $t7, skip_check_row_clears	# if $t0 != 1 then skip row clear check
# else
jal check_row_clears
jal check_game_over
# buffer
ori $v0, $0, 32
ori $a0, $0, 50
syscall

jal func_draw_rand
j game_loop

skip_check_row_clears:
# ----------------------------------------
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
# ----------------------------------------
# buffer
ori $v0, $0, 32
ori $a0, $0, 200
syscall

j game_loop
#---------------------------------------------------------------------------------
check_obstructions:

or $t6, $0, $s1		# copy original px regs to $t6-9
or $t7, $0, $s2
or $t8, $0, $s3
or $t9, $0, $s4

ori $t5, $0, 128
beq $t0, $t5, add_down_offset

addi $s1, $s1, 64	# add 64 to each px value
addi $s2, $s2, 64
addi $s3, $s3, 64
addi $s4, $s4, 64
j check_obstructions_start

add_down_offset:
addi $s1, $s1, 128	# add 128 to each px value
addi $s2, $s2, 128
addi $s3, $s3, 128
addi $s4, $s4, 128

check_obstructions_start:
# ----------------------------------------
# code for detecting an obstruction in a pixel on the bitmap display ($s1 in this case)
lw $t5, 0($s1)
sll $t5, $t5, 28
srl $t5, $t5, 28	# $t5 = 1 --> px was non-background

# now check that $s1 != $t6 && $s1 != $t7 ...
beq $s1, $t6, s1_matches_one_prev_address
beq $s1, $t7, s1_matches_one_prev_address
beq $s1, $t8, s1_matches_one_prev_address
beq $s1, $t9, s1_matches_one_prev_address

ori $t4, $0, 1		# $t4 = 1 --> px addr does not match any previous px address
j s1_no_match

s1_matches_one_prev_address:
ori $t4, $0, 0		# $t4 = 0 --> px addr matches a previous px address

s1_no_match:

and $t3, $t4, $t5	# $t3 = $t4 && $t5 so if $t3 = 1 then $s1 meets conditions for obstruction
# ----------------------------------------
# code for detecting an obstruction in a pixel on the bitmap display ($s2 in this case)
lw $t5, 0($s2)
sll $t5, $t5, 28
srl $t5, $t5, 28	# $t5 = 1 --> px was non-background

# now check that $s2 != $t6 && $s2 != $t7 ...
beq $s2, $t6, s2_matches_one_prev_address
beq $s2, $t7, s2_matches_one_prev_address
beq $s2, $t8, s2_matches_one_prev_address
beq $s2, $t9, s2_matches_one_prev_address

ori $t4, $0, 1		# $t4 = 1 --> px addr does not match any previous px address
j s2_no_match

s2_matches_one_prev_address:
ori $t4, $0, 0		# $t4 = 0 --> px addr matches a previous px address

s2_no_match:

and $t4, $t4, $t5	# $t4 = $t4 && $t5 so if $t4 = 1 then $s2 meets conditions for obstruction
or $t3, $t3, $t4	# $t3 = $t3 || $t4 so if $t3 = 1 then there is at least one obstruction
# ----------------------------------------
# code for detecting an obstruction in a pixel on the bitmap display ($s3 in this case)
lw $t5, 0($s3)
sll $t5, $t5, 28
srl $t5, $t5, 28	# $t5 = 1 --> px was non-background

# now check that $s3 != $t6 && $s3 != $t7 ...
beq $s3, $t6, s3_matches_one_prev_address
beq $s3, $t7, s3_matches_one_prev_address
beq $s3, $t8, s3_matches_one_prev_address
beq $s3, $t9, s3_matches_one_prev_address

ori $t4, $0, 1		# $t4 = 1 --> px addr does not match any previous px address
j s3_no_match

s3_matches_one_prev_address:
ori $t4, $0, 0		# $t4 = 0 --> px addr matches a previous px address

s3_no_match:

and $t4, $t4, $t5	# $t4 = $t4 && $t5 so if $t4 = 1 then $s3 meets conditions for obstruction
or $t3, $t3, $t4	# $t3 = $t3 || $t4 so if $t3 = 1 then there is at least one obstruction
# ----------------------------------------
# code for detecting an obstruction in a pixel on the bitmap display ($s4 in this case)
lw $t5, 0($s4)
sll $t5, $t5, 28
srl $t5, $t5, 28	# $t5 = 1 --> px was non-background

# now check that $s4 != $t6 && $s4 != $t7 ...
beq $s4, $t6, s4_matches_one_prev_address
beq $s4, $t7, s4_matches_one_prev_address
beq $s4, $t8, s4_matches_one_prev_address
beq $s4, $t9, s4_matches_one_prev_address

ori $t4, $0, 1		# $t4 = 1 --> px addr does not match any previous px address
j s4_no_match

s4_matches_one_prev_address:
ori $t4, $0, 0		# $t4 = 0 --> px addr matches a previous px address

s4_no_match:

and $t4, $t4, $t5	# $t4 = $t4 && $t5 so if $t4 = 1 then $s4 meets conditions for obstruction
or $t3, $t3, $t4	# $t3 = $t3 || $t4 so if $t3 = 1 then there is at least one obstruction
# ----------------------------------------
beq $t3, $0, no_obstruction
ori $t0, $0, 1		# $t0 = 1
jr $ra
no_obstruction:     	# no obstruction --> continues as normal
or $s1, $0, $t6
or $s2, $0, $t7
or $s3, $0, $t8
or $s4, $0, $t9
jr $ra
#---------------------------------------------------------------------------------
check_row_clears:	# !!!!!!!!!!!!! ROW CLEAR CHECK FUNCTION STARTS HERE !!!!!!!!!!!!!
ori $t2, $0, 1		# $t2 keeps track of px #; px # = 1 --> start by checking $s1
check_px:
ori $t3, $0, 1
ori $t4, $0, 2
ori $t5, $0, 3
ori $t6, $0, 4
beq $t2, $t3, load_s1
beq $t2, $t4, load_s2
beq $t2, $t5, load_s3
beq $t2, $t6, load_s4
j exit_check_row_clears
load_s1:
or $t7, $0, $s1
j cont_check_px
load_s2:
or $t7, $0, $s2
j cont_check_px
load_s3:
or $t7, $0, $s3
j cont_check_px
load_s4:
or $t7, $0, $s4
j cont_check_px
cont_check_px:
# ----------------------------------------
# $t3 = 1 --> all filled; clear row, $t3 = 0 --> not all filled; don't clear row
# calculate base address $t7
ori $t8, $0, 64		# $t8 = 64
div $t7, $t8		# hi = px address % 64
mfhi $t8		# $t8 = px address % 64
sub $t7, $t7, $t8	# $t7 = px address - (px address % 64)
ori $t8, $0, 64		# $t8 = 64 again
sub $t7, $t7, $t8	# $t7 = [px address - (px address % 64)] - 64

ori $t4, $0, 0		# $t4 = 0 (initializing for loop)

loop_thru_row:
ori $t5, $0, 64
beq $t4, $t5, exit_loop_thru_row
beq $t3, $0, exit_loop_thru_row		# also exit if $t3 (boolean indicator) = 0

add $t8, $t7, $t4	# position to check ($t8) = base addr ($t7) + offset ($t4)

lw $t8, 0($t8)		# $t8 = hex color of current pixel
sll $t8, $t8, 28
srl $t8, $t8, 28	# if $t8 = 1 --> hex color of current pixel is non-background

and $t3, $t3, $t8	# AND $t3 (boolean indicator) w/ $t8

addi $t4, $t4, 4	# incr counter

j loop_thru_row
exit_loop_thru_row:
# ----------------------------------------
# check: do we clear the row?
beq $t3, $0, no_clear

ori $t4, $0, 0		# reset offset $t4
clear_row:
ori $t5, $0, 64
beq $t4, $t5, exit_clear_row

add $t8, $t7, $t4	# position to check ($t8) = base addr ($t7) + offset ($t4)
sw $s7, 0($t8)		# $t8 hex color = #000000 (background)

addi $t4, $t4, 4	# incr counter
j clear_row
exit_clear_row:
# ----------------------------------------
# bring rows from above down after row clear
bring_rows_down:
addi $t7, $t7, -64	# subtract 64 from $t7 --> check above row
# ----------------------------------------
ori $t3, $0, 0		# $t3 (boolean indicator) = 0
ori $t4, $0, 0		# reset offset $t4
check_if_empty:
ori $t5, $0, 64
beq $t4, $t5, exit_check_if_empty
bne $t3, $0, exit_check_if_empty	# also exit if $t3 (boolean indicator) is no longer 0

add $t8, $t7, $t4	# position to check ($t8) = base addr ($t7) + offset ($t4)
lw $t8, 0($t8)		# $t8 = hex color of current pixel
sll $t8, $t8, 28
srl $t8, $t8, 28	# if $t8 = 1 --> hex color of current pixel is non-background

or $t3, $t3, $t8	# OR so if any $t8 = 1 then $t3 = 1

addi $t4, $t4, 4
j check_if_empty
exit_check_if_empty:

ori $t4, $0, 0		# reset offset $t4
copy_to_below:
ori $t5, $0, 64
beq $t4, $t5, exit_copy_to_below

add $t9, $t7, $t4	# $t9 = base addr ($t7) + offset ($t4)
lw $t8, 0($t9)		# $t8 = hex color of current pixel
addi $t9, $t9, 64	# add 64 to go down 1 row
# ----------------------------------------
# if $t9 = $s1, $s2, $s3, or $s4 --> $s1 = $s1 + 64, $s2 = $s2 + 64, etc. ...
beq $t9, $s1, cpy2b_update_s1
beq $t9, $s2, cpy2b_update_s2
beq $t9, $s3, cpy2b_update_s3
beq $t9, $s4, cpy2b_update_s4
j cpy2b_cont

cpy2b_update_s1:
addi $s1, $s1, 64
j cpy2b_cont
cpy2b_update_s2:
addi $s2, $s2, 64
j cpy2b_cont
cpy2b_update_s3:
addi $s3, $s3, 64
j cpy2b_cont
cpy2b_update_s4:
addi $s4, $s4, 64
cpy2b_cont:
# ----------------------------------------
# lw $t8, 0($t9)	# $t8 = hex color of current pixel
# addi $t9, $t9, 64	# add 64 to go down 1 row
sw $t8, 0($t9)

addi $t4, $t4, 4
j copy_to_below
exit_copy_to_below:

# $t3 = 0 --> row is empty, $t3 = 1 --> row is not empty
beq $t3, $0, exit_bring_rows_down
# ----------------------------------------
j bring_rows_down
exit_bring_rows_down:
# ----------------------------------------
no_clear:
addi $t2, $t2, 1	# check next px
j check_px

exit_check_row_clears:
jr $ra
#---------------------------------------------------------------------------------
check_game_over:
# concept: if any one of a block's pixels are in the top row after it stops falling then the game is over
ori $t2, $0, 0x10010000	# base addr.

ori $t3, $0, 0		# counter/offset
ori $t4, $0, 64		# comp. value

loop_thru_top_row:
beq $t3, $t4, end_loop_thru_top_row	# if counter/offset = 64 then exit loop
# else
add $t5, $t2, $t3	# $t6 = base addr. + offset

beq $s1, $t5, quit
beq $s2, $t5, quit
beq $s3, $t5, quit
beq $s4, $t5, quit

addi $t3, $t3, 4	# incr counter
j loop_thru_top_row
end_loop_thru_top_row:

jr $ra
#---------------------------------------------------------------------------------
quit:
