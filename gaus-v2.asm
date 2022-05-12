### Text segment
		.text
start:
		la		$a0, matrix_4x4		# a0 = A (base address of matrix)
		li		$a1, 4				# a1 = N (Number of elems)
		li		$a2, 2    		    # a2 = B (Block size)
									# <debug>
		jal 	print_matrix	    # print matrix before elimination
		nop							# </debug>
		jal 	eliminate			# triangularize matrix!
		nop							# <debug>
		jal 	print_matrix		# print matrix after elimination
		nop							# </debug>
		jal 	exit

exit:
		li   	$v0, 10          	# specify exit system call
      	syscall						# exit program

# a0 = A		
# a1 = N
# a2 = B
# t9 = B
# s0 = M
# s1 = I
# s2 = J
# s3 = k
# s4 = MIN THING
# s5 = j
# s6 = M(I + 1) - 1
# s7 = M(J + 1) - 1
# s8 = i


eliminate:
		addiu	$sp, $sp, -4		# allocate stack frame
		sw		$ra, 0($sp)			# done saving registers
		move 	$t9, $a2 			#t9 = B
		div 	$s0, $a1, $t9 			#M = N/B, s0 = M

		add 	$s1, $zero, $zero	#s1 = I, I = 0
for_loop_I:
		bge 	$s1, $t9, program_end

		add		$s2, $zero, $zero	# s2 = J, J = 0
for_loop_J:
		bge		$s2, $t9, for_loop_I_end

		#### ASSIGN M(I + 1) - 1
		#### ASSIGN M(J + 1) - 1
		addi	$t1, $s1, 1
		addi	$t3, $s2, 1
		mul	$t2, $t1, $s0
		mul	$t4, $t3, $s0
		subi	$s6, $t2, 1
		subi	$s7, $t4, 1
		########################
		move 	$t1, $s2		# t1 = $t1
		blt		$s2, $s1, before_k_loop 	# if J < I, do not reassign I to t1
		nop
		move 	$t1, $s1			# $t1 = J
before_k_loop:
		add		$s3, $zero, $zero	# $s3 = k, k = 0
		
		
for_loop_k:
		bgt 	$s3, $t1, for_loop_J_end

		mul		$t1, $s1, $s0		#t1 = I*M
		blt		$s3, $t1, before_loop_i
		bgt		$s3, $s6, before_loop_i
		nop

if1:
		addi	$t2, $s3, 1			# $t2 = k + 1
		mul		$t3, $s0, $s2		# t3 = M*J
		bge		$t2, $t3, if1B		# if $t2 >= $t1 then target
		nop
		move 	$t2, $t3			# $t2 = M*J
if1B:	
		move	$s5, $t2			# j = 0
		
		
		
for_loop_j: ### j is $s5
		bge		$s5, $s7, for_loop_k_end	# if j >= M(J + 1) - 1 then before_loop_i
		nop
		###################################
		move 	$a2, $s3		# $a2 = $s3
		move 	$a3, $s3		# $a2 = $s3
		jal		new_get_elem			#get kk
		mov.s 	$f1, $f0				#t1 = A[k][k]
		move 	$a3, $s5		# $a2 = $s3
		jal		new_get_elem			#getkj
		div.s	$f0, $f1, $f0
		s.s	$f0, 0($v0)
		###################################
		
		#		set_k_j
for_loop_j_end:
		addi	$s5, $s5, 1
		b for_loop_j
		nop
if2:
		bne				$s5, $a1, before_loop_i	# if $s5 != $t1 then target
		nop
		jal				new_get_elem
		nop
		l.s				$f0, 1
		nop
		s.s				$f0, 0($v0)


before_loop_i:
		addi		$s7, $s3, 1		# i = k + 1
		mul			$t1, $s0, $s1	# t1 = I * M
		blt			$s7, $t1, for_loop_i	# if $t0 < $t1 then for_loop_i
		nop
		move		$s7, $t1
		
for_loop_i:
	bgt		$s7, $s6, if3	# if $s7 > $s6 then if3
	
before_loop_j2:
		addi		$s5, $s3, 1		# i = k + 1
		mul			$t1, $s0, $s2	# t1 = J * M
		blt			$s5, $t1, for_loop_i_end	# if $t0 < $t1 then for_loop_i
		nop
		move		$s5, $t1
for_loop_j2:
		move 		$a3, $s3		# a3 = k
		move		$a4, $s5		# a4 = j
		b			new_get_elem:
		mov.s		$f1, $f0
		move 		$a3, $s8		# a3 = i
		move		$a4, $s3		# a4 = k
		b			new_get_elem:
		mul.s		$f1, $f0, $f1	# f1 = A[i][k] * A[k][j]
		move		$a4, $s5		# a4 = j
		b			new_get_elem:
		sub.s		$f0, $f0, $f1	# f0 = A[i][j] - A[i][k] * A[k][j]
		nop
		s.s			$f0, 0($v0)

for_loop_j2_end:
		addi	$s5, $s5, 1			#j++
		b for_loop_j2
for_loop_i_end:
		addi	$s7, $s7, 1			# i++
		b for_loop_i
		nop

if3:
		bne		$s5, $a1, for_loop_k_end	# if j != N then for_loop_k_end
		move 		$a3, $s8		# a3 = i
		move		$a4, $s3		# a4 = k
		b			new_get_elem:
		l.s			$f0, 0
		nop
		s.s			$f0, 0($v0)
	

for_loop_k_end:
		addi	$s3, $s3, 1			# k++
		b		for_loop_k			# branch to for_loop_k
		nop
		
for_loop_J_end:
		addi	$s2, $s2, 1			# J++
		b		for_loop_J			# branch to for_loop_I
		nop
for_loop_I_end:
		addi	$s1, $s1, 1			# I++
		b		for_loop_I			# branch to for_loop_I
		nop
		
		

program_end:
		lw		$ra, 0($sp)			# done restoring registers
		addiu	$sp, $sp, 4			# remove stack frame

		jr		$ra					# return from subroutine
		nop							# this is the delay slot associated with all types of jumps

# a1 = N
# a2 = B
# t9 = B
# s0 = M
# s1 = I
# s2 = J
# s3 = k
# s4 = MIN THING
# s5 = j

# Args:
#		$a0 - base address of matrix (A)
#		$a1 - Number of elements per row (N)
# 		$a2 - Row number (a)
#		$a3 - Column number (b)

#		$f0 -> Value
#		$v0 -> Address
new_get_elem:
		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$a2, $t1
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a
		sll		$t3, $a3, 2			# s0 = 4*b (byte offset of column b)
		addu	$v0, $t2, $t3		# Now we have address to A[a][b] in v0
		l.s		$f0, 0($v0)		    # ... and contents of A[a][b] in f0
		jr		$ra					# jump to $ra
		

##########################################################
print_matrix:
		addiu	$sp,  $sp, -20		# allocate stack frame
		sw		$ra,  16($sp)
		sw      $s2,  12($sp)
		sw		$s1,  8($sp)
		sw		$s0,  4($sp) 
		sw		$a0,  0($sp)		# done saving registers

		move	$s2,  $a0			# s2 = a0 (array pointer)
		move	$s1,  $zero			# s1 = 0  (row index)
loop_s1:
		move	$s0,  $zero			# s0 = 0  (column index)
loop_s0:
		l.s		$f12, 0($s2)        # $f12 = A[s1][s0]
		li		$v0,  2				# specify print float system call
 		syscall						# print A[s1][s0]
		la		$a0,  spaces
		li		$v0,  4				# specify print string system call
		syscall						# print spaces

		addiu	$s2,  $s2, 4		# increment pointer by 4

		addiu	$s0,  $s0, 1        # increment s0
		blt		$s0,  $a1, loop_s0  # loop while s0 < a1
		nop
		la		$a0,  newline
		syscall						# print newline
		addiu	$s1,  $s1, 1		# increment s1
		blt		$s1,  $a1, loop_s1  # loop while s1 < a1
		nop
		la		$a0,  newline
		syscall						# print newline

		lw		$ra,  16($sp)
		lw		$s2,  12($sp)
		lw		$s1,  8($sp)
		lw		$s0,  4($sp)
		lw		$a0,  0($sp)		# done restoring registers
		addiu	$sp,  $sp, 20		# remove stack frame

		jr		$ra					# return from subroutine
		nop							# this is the delay slot associated with all types of jumps

##############################################
### End of text segment

### Data segment 
		.data
		
### String constants
spaces:
		.asciiz "   "   			# spaces to insert between numbers
newline:
		.asciiz "\n"  				# newline

## Input matrix: (4x4) ##
matrix_4x4:	
		.float 57.0
		.float 20.0
		.float 34.0
		.float 59.0
		
		.float 104.0
		.float 19.0
		.float 77.0
		.float 25.0
		
		.float 55.0
		.float 14.0
		.float 10.0
		.float 43.0
		
		.float 31.0
		.float 41.0
		.float 108.0
		.float 59.0
		
		# These make it easy to check if 
		# data outside the matrix is overwritten
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef
		.word 0xdeadbeef