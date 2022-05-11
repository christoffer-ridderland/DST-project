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
		
# a1 = N
# a2 = B
# t9 = B
# s0 = M
# s1 = I
# s2 = J
# s3 = k
# s4 = MIN THING
# s5 = j


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
		move	$t1, $s2, 			# t1 = J
		blt		$s2, $s1, before_k_loop 	# if J < I, do not reassign I to t1
		nop
		move 	$t1, $s1			# $t1 = J
before_k_loop:
		addi 	$t1, $s1, 1			#t1 = I/J + 1 
		mul		$s4, $s0, $t1		#t2 = M(I/J + 1)
		subi	$s4, $s4, 1			#t2 = M(I/J + 1) - 1
		add		$s3, $zero, $zero	# $s3 = k, k = 0
		
		
for_loop_k:
		bgt 	$s3, $s4, for_loop_J_end
		mul		$t1, $s1, $s0		#t1 = I*M
		blt		$s3, $t1, for_loop_j
		addi 	$t1, $s1, 1			#t1 = I + 1 
		mul		$t2, $s0, $t1		#t2 = M(I + 1)
		subi	$t2, $t2, 1			#t2 = M(I + 1) - 1
		bgt		$s3, $t1, for_loop_j

if1:
		addi 	$t1, $s2, 1			#t1 = I + 1 
		mul		$t2, $s0, $t1		#t2 = M(I + 1)
		subi	$t2, $t2, 1			#t2 = M(I + 1) - 1
		addi	$t3, $s3, 1			# $t3 = k + 1
		mul		$t4, $s0, $s2		# t4 = M*J

		bgt		$t4, $t3, for_loop_j	# if $t4 > $t1 then target
		nop
		move 	$t3, $t4			# $t3 = $t4
		
for_loop_j: ### j is $t3
		bgt		$t3, $t2, for_loop_i

for_loop_j_end:
		addi	$t3, $t3, 1
		b for_loop_j
		nop
if2:
for_loop_i:
for_loop_j2:
for_loop_j2_end:
for_loop_i_end:

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