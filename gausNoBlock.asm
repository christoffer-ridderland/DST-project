# a0 = A		
# a1 = N
# s0 = i
# s1 = j
# s2 = k
# s3 = 1
# f7 = 1.s

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

eliminate:
		addiu	$sp, $sp, -4		# allocate stack frame
		sw		$ra, 0($sp)			# done saving registers
		addi	$s3, $zero, 1
		mtc1 	$s3, $f7
  		cvt.s.w $f7, $f7
		add		$s2, $zero, $zero		# k = 0

for_k:
		bge		$s2, $a1, end_program	# if k >= n then target
		addi	$s1, $s2, 1				# j = k+1

for_j1:
		bge		$s1, $a1, set_one	# if k >= n then target
		#############
		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$s2, $t1
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a

		sll		$t3, $s2, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t3	# Now we have address to A[a][b] in v0
		lwc1	$f0, 0($t1)	# ... and contents of A[k][k] in f0

		sll		$t4, $s1, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t4	# Now we have address to A[a][b] in v0
		lwc1	$f1, 0($t1)	# ... and contents of A[k][k] in f0

		div.s	$f2, $f1, $f0
		swc1	$f2, 0($t1)
		##############
for_j1_end:
		b		for_j1
		addi	$s1, $s1, 1

set_one:
		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$s2, $t1
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a

		sll		$t3, $s2, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t3	# Now we have address to A[a][b] in v0
		
		addi	$t4, $zero, 1

		swc1	$f7, 0($t1)

		addi	$s0, $s2, 1

for_i:
		bge		$s0, $a1, for_k_end
		addi	$s1, $s2, 1

for_j2:
		bge		$s1, $a1, set_zero

		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$s2, $t1
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a

		sll		$t3, $s1, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t3	# Now we have address to A[a][b] in v0
		lwc1	$f0, 0($t1)	# ... and contents of A[k][j] in f0				#A[k][j]

		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$s0, $t1
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a

		sll		$t4, $s2, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t4	# Now we have address to A[a][b] in v0
		lwc1	$f1, 0($t1)	# ... and contents of A[k][j] in f0				#A[i][k]

		sll		$t4, $s1, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t4	# Now we have address to A[a][b] in v0
		lwc1	$f3, 0($t1)	# ... and contents of A[k][j] in f0				#A[i][j]

		mul.s	$f4, $f0, $f1
		sub.s	$f2, $f3, $f4

		swc1	$f2, 0($t1)


for_j2_end:
		b	for_j2
		addi	$s1, $s1, 1			# j++
		
set_zero:
		sll		$t1, $a1, 2			# s2 = 4*N (number of bytes per row)
		multu	$s0, $t1
		mflo	$t2
		addu	$t2, $t2, $a0		# Now t2 contains address to row a

		sll		$t4, $s2, 2			# t3 = 4*b (byte offset of column b)
		addu	$t1, $t2, $t4		# Now we have address to A[a][b] in v0
		add		$t2, $zero, $zero
		sw		$t2, 0($t1)			# 
		

for_i_end:
		b		for_i			# branch to for_i
		addi	$s0, $s0, 1		# i++

for_k_end:
		b		for_k
		addi	$s2, $s2, 1		# i++
end_program:
		lw		$ra, 0($sp)			# done restoring registers
		addiu	$sp, $sp, 4			# remove stack frame

		jr		$ra					# return from subroutine
		nop							# this is the delay slot associated with all types of jumps

		


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