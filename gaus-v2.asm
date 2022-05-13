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
# a3 = M
# s0
# s1 = I
# s2 = J
# s3 = k
# s4 = MIN THING / i
# s5 = j
# s6 = M(I + 1) - 1
# s7 = M(J + 1) - 1



eliminate:
		addiu	$sp, $sp, -4		# allocate stack frame
		sw		$ra, 0($sp)			# done saving registers
		div 	$a3, $a1, $a2 		# M = N/B, a3 = M

		add 	$s1, $zero, $zero	# s1 = I, I = 0
for_loop_I:
		bge 	$s1, $a2, program_end
		#### ASSIGN M(I + 1) - 1
		addi	$t1, $s1, 1
		mul		$t2, $t1, $a3
		add		$s2, $zero, $zero	# s2 = J, J = 0
		subi	$s6, $t2, 1

for_loop_J:
		bge		$s2, $a2, for_loop_I_end

		#### ASSIGN M(J + 1) - 1
		
		addi	$t3, $s2, 1
		mul		$t4, $t3, $a3
		subi	$s7, $t4, 1
		########################
		move 	$t8, $s7		# t1 = $s2
		ble		$s7, $s6, before_k_loop 	# if J < I, do not reassign I to t1
		nop
		move 	$t8, $s6			# $t1 = J
before_k_loop:
		add		$s3, $zero, $zero	# $s3 = k, k = 0
		
		
for_loop_k:

		bgt 	$s3, $t8, for_loop_J_end

		mul		$t1, $s1, $a3		#t1 = I*M
		bgt		$s3, $s6, before_loop_i
		blt		$s3, $t1, before_loop_i
		nop

if1:
		addi	$t2, $s3, 1			# $t2 = k + 1
		mul		$t3, $a3, $s2		# t3 = M*J
		bge		$t2, $t3, if1B		# if $t2 >= $t1 then target
		nop
		move 	$t2, $t3			# $t2 = M*J
if1B:	
		move	$s5, $t2			# j = t2
		
		
		
for_loop_j: ### j is $s5
		bge		$s5, $s7, if2	# if j >= M(J + 1) - 1 then before_loop_i
		nop
		

		################################### GET A[k][k]
		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		mul		$t2, $s3, $t1
		addu	$t2, $t2, $a0			# Now t2 contains address to row a
		sll		$t3, $s3, 2			# s0 = 4*b (byte offset of column b)
		addu	$t4, $t2, $t3	# Now we have address to A[a][b] in v0
		l.s		$f1, 0($t4)	# ... and contents of A[a][b] in f0

		################################## GET A[k][j]
		sll		$t3, $s5, 2			# s0 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t3	# Now we have address to A[a][b] in v0
		l.s		$f0, 0($t1)	# ... and contents of A[a][b] in f0

		div.s	$f0, $f0, $f1
		s.s		$f0, 0($t1)
		###################################
		
		#		set_k_j
for_loop_j_end:

		addi	$s5, $s5, 1
		b for_loop_j
if2:
		bne				$s5, $a1, before_loop_i	# if $s5 != $t1 then target
		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		mul		$t2, $s3, $t1
		addu	$t2, $t2, $a0			# Now t2 contains address to row a
		sll		$t3, $s3, 2			# s0 = 4*b (byte offset of column b)
		addu	$t4, $t2, $t3	# Now we have address to A[a][b] in v0
		addi			$t0, $zero, 1
		sw				$t0, 0($t4)


before_loop_i:
		addi		$s4, $s3, 1		# i = k + 1
		mul			$t1, $a3, $s1	# t1 = I * M
		bge			$t1, $s4, for_loop_i	# if $t0 < $t1 then for_loop_i
		nop
		move		$s4, $t1
		
for_loop_i:
		bgt		$s4, $s6, for_loop_k_end	# if $t2 > $s6 then if3
	
before_loop_j2:
		addi		$s5, $s3, 1		# j = k + 1
		mul			$t1, $a3, $s2	# t1 = J * M
		ble			$s5, $t1, for_loop_j2	# if $t0 < $t1 then for_loop_i
		nop
		move		$s5, $t1
for_loop_j2:
		bgt			$s5, $s7, if3

		# t4 = N*4
		# f0 = A[k][j]
		# f1 = A[i][j]
		# t6 = *A[i][k]
		# t7 = *A[i][j]
		# f2 = A[i][k]
		# j*4 + k*24*4
		###Kan optimeras, kolla inte samma elem massa gånger
		###
		################################## Get A[k][j]
		sll		$t4, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$s3, $t4
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a
		sll		$t3, $s5, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t3	# Now we have address to A[a][b] in v0
		l.s		$f0, 0($t1)	# ... and contents of A[k][j] in f0
		################################## Get[i][j] with address
		multu	$s4, $t4
		mflo	$t2
		addu	$t2, $t2, $a0			# Now t2 contains address to row a
		sll		$t3, $s5, 2			# s0 = 4*b (byte offset of column b)
		addu	$t7, $t2, $t3	# Now we have address to A[a][b] in v0
		l.s		$f1, 0($t7)	# ... and contents of A[a][b] in f0
		################################## Get[i][k]
		sll		$t3, $s3, 2			# s0 = 4*b (byte offset of column b)
		addu	$t6, $t2, $t3	# Now we have address to A[a][b] in v0
		l.s		$f2, 0($t6)	# ... and contents of A[a][b] in f0
		####################################

		mul.s		$f3, $f0, $f2	# f1 = A[i][k] * A[k][j]
		sub.s		$f1, $f1, $f3	# f0 = A[i][j] - A[i][k] * A[k][j]
		s.s			$f1, 0($t7)

for_loop_j2_end:
		addi	$s5, $s5, 1			#j++
		b for_loop_j2
		nop

if3:
		bne		$s5, $a1, for_loop_k_end	# if j != N then for_loop_k_end
		nop
		add			$t0, $zero, $zero
		nop
		sw			$t0, 0($t6)

for_loop_i_end:
		addi	$s4, $s4, 1			# i++
		b for_loop_i
		nop


	
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
# a3 = M
# t9 = B
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
#new_get_elem:
#		sll		$t1, N, 2			# s2 = 4*N (number of bytes per row)
#		multu	X, $t1
#		mflo	$t2
#		addu	$t2, $t2, A			# Now t2 contains address to row a
#		sll		$t3, Y, 2			# s0 = 4*b (byte offset of column b)
#		addu	ADDRESS, $t2, $t3	# Now we have address to A[a][b] in v0
#		l.s		DATA, 0(ADDRESS)	# ... and contents of A[a][b] in f0
#		jr		$ra					# jump to $ra
		

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