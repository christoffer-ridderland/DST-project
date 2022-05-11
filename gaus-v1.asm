### Text segment
		.text
start:
		la		$a0, matrix_4x4		# a0 = A (base address of matrix)
		li		$a1, 4
		li		$a2, 2    		    # a1 = N (number of elements per row)
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

################################################################################
# eliminate - Triangularize matrix.
#
# Args:		$a0  - base address of matrix (A)
#			$a1  - number of elements per row (N)

#	s0 = M
#	s1 = I
#	s2 = J
# 	s3 = k	
#	s4 = i	
#	s5 = j
#	s6 = M(I + 1) - 1
#	s7 = M(J + 1) - 1
# 	t9 = B			spara B???	Skydda a2 register? 

eliminate:
		# If necessary, create stack frame, and save return address from ra
		addiu	$sp, $sp, -4		# allocate stack frame
		sw	$ra, 0($sp)			# done saving registers
		move 	$t9, $a2 	#t9 = B
		##
		## Implement eliminate here
		## 
		div $s0, $a1, $t9 #M = N/B, s0 = M
		
		add $s1, $zero, $zero  #s1 = I
row_block_loop:
			bge $s1, $t9, end_of_loops	#done if I > B
			#set M(I + 1) - 1 här
			addi $t1, $s1, 1	#t1 = J + 1 
			mul $t2, $s0, $t1	#t2 = M(J + 1)
			add $s2, $zero, $zero	#t2 = J
			subi $s6, $t2, 1	#s6 = M(J + 1) - 1
col_block_loop:
				bge $s2, $t9, end_of_row_block_loop #inc I if J > B
				addi  $t1, $s2, 1	#t1 = J + 1 
				mul   $t2, $s0, $t1	#t2 = M(J + 1)
				add $s3, $zero, $zero	#t3 = k
				subi  $s7, $t2, 1	#s7 = M(J + 1) - 1
k_loop:	
					bgt   $s3, $s6, end_of_col_block_loop
					bgt   $s3, $s7, end_of_col_block_loop
					mul   $t0, $s0, $s1 #t0 = M * I
					blt   $s3, $t0, pivot_not_in_block #branch if k < M * I
					bgt   $s3, $t2, pivot_not_in_block #branch if k > M(I + 1) ########################
pivot_check:
						addi  $t0, $s3, 1 	#t0 = k + 1
						mul   $t1, $s0, $s2	#t1 = J * M
						bgt   $t0, $t1, j_1_left	#branch if k + 1 > J * M
						b     j_1_right		#branch to K1 #############VARNING KAN BLI fel här????
						add   $s5, $t0, $zero	#j = k + 1 ###########
j_1_left:
						mul   $s5, $t1, $zero	#j = J * M 	########### + eller *
j_1_right:					
						bgt   $s5, $s7, before_second_loop #branch if 
							move $a2, $s3		#a2 = k				############spara B här på nått sätt?
							####################jal getelem		#v0 = addres to A[k][k] and f0 = value of A[k][k]
							sll	$t2, $a1, 2			# s2 = 4*N (number of bytes per row)
							mulu	$t1, $a2, $t2			# result will be 32-bit unless the matrix is huge
							addu	$t1, $t1, $a0		# Now s1 contains address to row a
							sll	$t0, $s3, 2			# s0 = 4*b (byte offset of column b)
							addu	$v0, $t1, $t0		# Now we have address to A[a][b] in v0...
							l.s	$f0, 0($v0)	
							############################
							sub  $t6, $s5, $s3	#t6 = j - k
							addi  $t7, $zero, 4	#t7 = 4
							mul  $t6, $t6, $t7	#t6 = 4 * t6
							add $t6, $t6, $v0	#t6 = j - k + Address of A[k][k]
							addi  $s5, $s5, 1	#j = j + 1
							l.s  $f1, 0($t6)	#f1 = A[k][j]
							div.s $f2, $f1, $f0	#f2 = A[k][j]/A[k][k]
							sub.s $f3, $f1, $f2	#f3 = A[k][j] - A[k][j]/A[k][k]
							b j_1_right			#branch to loop check
							s.s   $f3, 0($t6)	#A[k][j] = A[k][j] - A[k][j]/A[k][k]
set_one:
						bne $s5, $a1, before_second_loop	#is last element in row? if no then branch out of loop //break;
							move $a2, $s3		#a2 = k
							############################
							sll	$t2, $a1, 2			# s2 = 4*N (number of bytes per row)
							mulu	$t1, $a2, $t2			# result will be 32-bit unless the matrix is huge
							addu	$t1, $t1, $a0		# Now s1 contains address to row a
							sll	$t0, $s3, 2			# s0 = 4*b (byte offset of column b)
							addu	$v0, $t1, $t0		# Now we have address to A[a][b] in v0...	
							############################
							addi $t0, $zero, 1	#t0 = 1
							sw  $t0, 0($v0)		#A[k][k] = 1
pivot_not_in_block:
before_second_loop:	
i_loop:
					addi $t8, $t3, 1 			#t8 = k + 1
					mul $t0, $s1, $s0			#t0 = M * I
					blt $t8, $t0, i_left			#branch if (k+1) < (M * I)
					b i_right				#branch to after i loop init
					move $s4, $t8				#i = k + 1
i_left:
					move $s4, $t0				#i = M * I
i_right:				
i_loop_check:
					bgt $s4, $s6, end_of_k_loop		#branch if i > M(I + 1) - 1
j_2_loop:
						addi $t7, $s3, 1		#t7 = k + 1
						mul $t6, $s2, $s0		#t6 = M * J
						blt $t7, $t6, j_2_left		#branch if (k + 1) < (M * J)     
						b j_2_right			#branch to after j 2 loop init    ### kanske kan ta bort denna och liknande rader. Man kan skriva och sen skriva ölver om det blev fel annars om det var rätt så hoppar man
						move $s5, $t7			#j = k + 1
j_2_left:
						move $s5, $t6			#j = M * J
j_2_right:					
j_2_loop_check:	
						bgt $s5, $s7, set_zero	#branch if j > M(J + 1) - 1
						move $a2, $s3			#a2 = k
						###############################
						sll	$t2, $a1, 2			# s2 = 4*N (number of bytes per row)
						mulu	$t1, $t2, $t2			# result will be 32-bit unless the matrix is huge
						addu	$t1, $t1, $a0		# Now s1 contains address to row a
						sll	$t0, $s5, 2			# s0 = 4*b (byte offset of column b)
						addu	$v0, $t1, $t0		# Now we have address to A[a][b] in v0...
						l.s	$f2, 0($v0)	
						##########################
						move $a3, $s5			#a3 = j
						move $a2, $s4			#a2 = i
						#################################
						sll	$t2, $a1, 2			# s2 = 4*N (number of bytes per row)
						mulu	$t1, $a2, $t2			# result will be 32-bit unless the matrix is huge
						addu	$t1, $t1, $a0		# Now s1 contains address to row a
						sll	$t0, $s3, 2			# s0 = 4*b (byte offset of column b)
						addu	$v0, $t1, $t0		# Now we have address to A[a][b] in v0...
						l.s	$f1, 0($v0)	
						############################
						mul.s $f3, $f2, $f1		#f3 = A[i][k] * A[k][j]
						###############################
						sll	$s2, $a1, 2			# s2 = 4*N (number of bytes per row)
						mulu	$t1, $a2, $t2			# result will be 32-bit unless the matrix is huge
						addu	$t1, $t1, $a0		# Now s1 contains address to row a
						sll	$t0, $s5, 2			# s0 = 4*b (byte offset of column b)
						addu	$v0, $t1, $t0		# Now we have address to A[a][b] in v0...
						l.s	$f0, 0($v0)	
						##############################
						sub.s $f4, $f0, $f3		#f4 = A[i][j] - A[i][k] * A[k][j]
						s.s  $f4, 0($v0)			#A[i][j] = A[i][j] - A[i][k] * A[k][j]

end_of_j_2_loop:
					b j_2_loop_check
					addi $s5, $s5, 1  	#j = j + 1
set_zero:				
					bne $a1, $s5, end_of_i_loop	#branch if element is not last the i loop check
						move $a2, $t4		#a2 = i 	######skydda B??
						jal getelem	
						move $a3, $t3		#a3 = k
						sw  $zero, 0($v0)	#A[i][k] = 0
						
end_of_i_loop:
					b i_loop_check		#jump back to check for loop i
					addi $s4, $s4, 1	#i = i + 1       increment i
end_of_k_loop:
				b k_loop		#jump back to check for k loop
				addi $s3, $s3, 1	#k = k + 1	increment k
end_of_col_block_loop:		
			b col_block_loop	#jump back to check for J loop	
			addi $s2, $s2, 1	#J = J + 1	incrent J
end_of_row_block_loop:
		b row_block_loop 	#jump back to check for I loop
		addi $s1, $s1, 1	#I = I + 1	increment I
end_of_loops:


		lw		$ra, 0($sp)			# done restoring registers
		addiu	$sp, $sp, 4			# remove stack frame

		jr		$ra					# return from subroutine
		nop							# this is the delay slot associated with all types of jumps


						# this is the delay slot associated with all types of jumps

################################################################################
# getelem - Get address and content of matrix element A[a][b].
#
# Argument registers $a0..$a3 are preserved across calls
#
# Args:		$a0  - base address of matrix (A)
#			$a1  - number of elements per row (N)
#			$a2  - row number (a)
#			$a3  - column number (b)
#						
# Returns:	$v0  - Address to A[a][b]
#			$f0  - Contents of A[a][b] (single precision)
getelem:
		addiu	$sp, $sp, -12		# allocate stack frame
		sw		$s2, 8($sp)
		sw		$s1, 4($sp)
		sw		$s0, 0($sp)			# done saving registers
		
		sll		$s2, $a1, 2			# s2 = 4*N (number of bytes per row)
		mulu	$s1, $a2, $s2			# result will be 32-bit unless the matrix is huge
		addu	$s1, $s1, $a0		# Now s1 contains address to row a
		sll		$s0, $a3, 2			# s0 = 4*b (byte offset of column b)
		addu	$v0, $s1, $s0		# Now we have address to A[a][b] in v0...
		l.s		$f0, 0($v0)		    # ... and contents of A[a][b] in f0.
		
		lw		$s2, 8($sp)
		lw		$s1, 4($sp)
		lw		$s0, 0($sp)			# done restoring registers
		jr		$ra					# return from subroutine
		addiu	$sp, $sp, 12		# remove stack frame
		



################################################################################
# print_matrix
#
# This routine is for debugging purposes only. 
# Do not call this routine when timing your code!
#
# print_matrix uses floating point register $f12.
# the value of $f12 is _not_ preserved across calls.
#
# Args:		$a0  - base address of matrix (A)
#			$a1  - number of elements per row (N) 
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

## Input matrix: (24x24) ##
matrix_24x24:
		.float	 92.00 
		.float	 43.00 
		.float	 86.00 
		.float	 87.00 
		.float	100.00 
		.float	 21.00 
		.float	 36.00 
		.float	 84.00 
		.float	 30.00 
		.float	 60.00 
		.float	 52.00 
		.float	 69.00 
		.float	 40.00 
		.float	 56.00 
		.float	104.00 
		.float	100.00 
		.float	 69.00 
		.float	 78.00 
		.float	 15.00 
		.float	 66.00 
		.float	  1.00 
		.float	 26.00 
		.float	 15.00 
		.float	 88.00 

		.float	 17.00 
		.float	 44.00 
		.float	 14.00 
		.float	 11.00 
		.float	109.00 
		.float	 24.00 
		.float	 56.00 
		.float	 92.00 
		.float	 67.00 
		.float	 32.00 
		.float	 70.00 
		.float	 57.00 
		.float	 54.00 
		.float	107.00 
		.float	 32.00 
		.float	 84.00 
		.float	 57.00 
		.float	 84.00 
		.float	 44.00 
		.float	 98.00 
		.float	 31.00 
		.float	 38.00 
		.float	 88.00 
		.float	101.00 

		.float	  7.00 
		.float	104.00 
		.float	 57.00 
		.float	  9.00 
		.float	 21.00 
		.float	 72.00 
		.float	 97.00 
		.float	 38.00 
		.float	  7.00 
		.float	  2.00 
		.float	 50.00 
		.float	  6.00 
		.float	 26.00 
		.float	106.00 
		.float	 99.00 
		.float	 93.00 
		.float	 29.00 
		.float	 59.00 
		.float	 41.00 
		.float	 83.00 
		.float	 56.00 
		.float	 73.00 
		.float	 58.00 
		.float	  4.00 

		.float	 48.00 
		.float	102.00 
		.float	102.00 
		.float	 79.00 
		.float	 31.00 
		.float	 81.00 
		.float	 70.00 
		.float	 38.00 
		.float	 75.00 
		.float	 18.00 
		.float	 48.00 
		.float	 96.00 
		.float	 91.00 
		.float	 36.00 
		.float	 25.00 
		.float	 98.00 
		.float	 38.00 
		.float	 75.00 
		.float	105.00 
		.float	 64.00 
		.float	 72.00 
		.float	 94.00 
		.float	 48.00 
		.float	101.00 

		.float	 43.00 
		.float	 89.00 
		.float	 75.00 
		.float	100.00 
		.float	 53.00 
		.float	 23.00 
		.float	104.00 
		.float	101.00 
		.float	 16.00 
		.float	 96.00 
		.float	 70.00 
		.float	 47.00 
		.float	 68.00 
		.float	 30.00 
		.float	 86.00 
		.float	 33.00 
		.float	 49.00 
		.float	 24.00 
		.float	 20.00 
		.float	 30.00 
		.float	 61.00 
		.float	 45.00 
		.float	 18.00 
		.float	 99.00 

		.float	 11.00 
		.float	 13.00 
		.float	 54.00 
		.float	 83.00 
		.float	108.00 
		.float	102.00 
		.float	 75.00 
		.float	 42.00 
		.float	 82.00 
		.float	 40.00 
		.float	 32.00 
		.float	 25.00 
		.float	 64.00 
		.float	 26.00 
		.float	 16.00 
		.float	 80.00 
		.float	 13.00 
		.float	 87.00 
		.float	 18.00 
		.float	 81.00 
		.float	  8.00 
		.float	104.00 
		.float	  5.00 
		.float	 57.00 

		.float	 19.00 
		.float	 26.00 
		.float	 87.00 
		.float	 80.00 
		.float	 72.00 
		.float	106.00 
		.float	 70.00 
		.float	 83.00 
		.float	 10.00 
		.float	 14.00 
		.float	 57.00 
		.float	  8.00 
		.float	  7.00 
		.float	 22.00 
		.float	 50.00 
		.float	 90.00 
		.float	 63.00 
		.float	 83.00 
		.float	  5.00 
		.float	 17.00 
		.float	109.00 
		.float	 22.00 
		.float	 97.00 
		.float	 13.00 

		.float	109.00 
		.float	  5.00 
		.float	 95.00 
		.float	  7.00 
		.float	  0.00 
		.float	101.00 
		.float	 65.00 
		.float	 19.00 
		.float	 17.00 
		.float	 43.00 
		.float	100.00 
		.float	 90.00 
		.float	 39.00 
		.float	 60.00 
		.float	 63.00 
		.float	 49.00 
		.float	 75.00 
		.float	 10.00 
		.float	 58.00 
		.float	 83.00 
		.float	 33.00 
		.float	109.00 
		.float	 63.00 
		.float	 96.00 

		.float	 82.00 
		.float	 69.00 
		.float	  3.00 
		.float	 82.00 
		.float	 91.00 
		.float	101.00 
		.float	 96.00 
		.float	 91.00 
		.float	107.00 
		.float	 81.00 
		.float	 99.00 
		.float	108.00 
		.float	 73.00 
		.float	 54.00 
		.float	 18.00 
		.float	 91.00 
		.float	 97.00 
		.float	  8.00 
		.float	 71.00 
		.float	 27.00 
		.float	 69.00 
		.float	 25.00 
		.float	 77.00 
		.float	 34.00 

		.float	 36.00 
		.float	 25.00 
		.float	  8.00 
		.float	 69.00 
		.float	 24.00 
		.float	 71.00 
		.float	 56.00 
		.float	106.00 
		.float	 30.00 
		.float	 60.00 
		.float	 79.00 
		.float	 12.00 
		.float	 51.00 
		.float	 65.00 
		.float	103.00 
		.float	 49.00 
		.float	 36.00 
		.float	 93.00 
		.float	 47.00 
		.float	  0.00 
		.float	 37.00 
		.float	 65.00 
		.float	 91.00 
		.float	 25.00 

		.float	 74.00 
		.float	 53.00 
		.float	 53.00 
		.float	 33.00 
		.float	 78.00 
		.float	 20.00 
		.float	 68.00 
		.float	  4.00 
		.float	 45.00 
		.float	 76.00 
		.float	 74.00 
		.float	 70.00 
		.float	 38.00 
		.float	 20.00 
		.float	 67.00 
		.float	 68.00 
		.float	 80.00 
		.float	 36.00 
		.float	 81.00 
		.float	 22.00 
		.float	101.00 
		.float	 75.00 
		.float	 71.00 
		.float	 28.00 

		.float	 58.00 
		.float	  9.00 
		.float	 28.00 
		.float	 96.00 
		.float	 75.00 
		.float	 10.00 
		.float	 12.00 
		.float	 39.00 
		.float	 63.00 
		.float	 65.00 
		.float	 73.00 
		.float	 31.00 
		.float	 85.00 
		.float	 31.00 
		.float	 36.00 
		.float	 20.00 
		.float	108.00 
		.float	  0.00 
		.float	 91.00 
		.float	 36.00 
		.float	 20.00 
		.float	 48.00 
		.float	105.00 
		.float	101.00 

		.float	 84.00 
		.float	 76.00 
		.float	 13.00 
		.float	 75.00 
		.float	 42.00 
		.float	 85.00 
		.float	103.00 
		.float	100.00 
		.float	 94.00 
		.float	 22.00 
		.float	 87.00 
		.float	 60.00 
		.float	 32.00 
		.float	 99.00 
		.float	100.00 
		.float	 96.00 
		.float	 54.00 
		.float	 63.00 
		.float	 17.00 
		.float	 30.00 
		.float	 95.00 
		.float	 54.00 
		.float	 51.00 
		.float	 93.00 

		.float	 54.00 
		.float	 32.00 
		.float	 19.00 
		.float	 75.00 
		.float	 80.00 
		.float	 15.00 
		.float	 66.00 
		.float	 54.00 
		.float	 92.00 
		.float	 79.00 
		.float	 19.00 
		.float	 24.00 
		.float	 54.00 
		.float	 13.00 
		.float	 15.00 
		.float	 39.00 
		.float	 35.00 
		.float	102.00 
		.float	 99.00 
		.float	 68.00 
		.float	 92.00 
		.float	 89.00 
		.float	 54.00 
		.float	 36.00 

		.float	 43.00 
		.float	 72.00 
		.float	 66.00 
		.float	 28.00 
		.float	 16.00 
		.float	  7.00 
		.float	 11.00 
		.float	 71.00 
		.float	 39.00 
		.float	 31.00 
		.float	 36.00 
		.float	 10.00 
		.float	 47.00 
		.float	102.00 
		.float	 64.00 
		.float	 29.00 
		.float	 72.00 
		.float	 83.00 
		.float	 53.00 
		.float	 17.00 
		.float	 97.00 
		.float	 68.00 
		.float	 56.00 
		.float	 22.00 

		.float	 61.00 
		.float	 46.00 
		.float	 91.00 
		.float	 43.00 
		.float	 26.00 
		.float	 35.00 
		.float	 80.00 
		.float	 70.00 
		.float	108.00 
		.float	 37.00 
		.float	 98.00 
		.float	 14.00 
		.float	 45.00 
		.float	  0.00 
		.float	 86.00 
		.float	 85.00 
		.float	 32.00 
		.float	 12.00 
		.float	 95.00 
		.float	 79.00 
		.float	  5.00 
		.float	 49.00 
		.float	108.00 
		.float	 77.00 

		.float	 23.00 
		.float	 52.00 
		.float	 95.00 
		.float	 10.00 
		.float	 10.00 
		.float	 42.00 
		.float	 33.00 
		.float	 72.00 
		.float	 89.00 
		.float	 14.00 
		.float	  5.00 
		.float	  5.00 
		.float	 50.00 
		.float	 85.00 
		.float	 76.00 
		.float	 48.00 
		.float	 13.00 
		.float	 64.00 
		.float	 63.00 
		.float	 58.00 
		.float	 65.00 
		.float	 39.00 
		.float	 33.00 
		.float	 97.00 

		.float	 52.00 
		.float	 18.00 
		.float	 67.00 
		.float	 57.00 
		.float	 68.00 
		.float	 65.00 
		.float	 25.00 
		.float	 91.00 
		.float	  7.00 
		.float	 10.00 
		.float	101.00 
		.float	 18.00 
		.float	 52.00 
		.float	 24.00 
		.float	 90.00 
		.float	 31.00 
		.float	 39.00 
		.float	 96.00 
		.float	 37.00 
		.float	 89.00 
		.float	 72.00 
		.float	  3.00 
		.float	 28.00 
		.float	 85.00 

		.float	 68.00 
		.float	 91.00 
		.float	 33.00 
		.float	 24.00 
		.float	 21.00 
		.float	 67.00 
		.float	 12.00 
		.float	 74.00 
		.float	 86.00 
		.float	 79.00 
		.float	 22.00 
		.float	 44.00 
		.float	 34.00 
		.float	 47.00 
		.float	 25.00 
		.float	 42.00 
		.float	 58.00 
		.float	 17.00 
		.float	 61.00 
		.float	  1.00 
		.float	 41.00 
		.float	 42.00 
		.float	 33.00 
		.float	 81.00 

		.float	 28.00 
		.float	 71.00 
		.float	 60.00 
		.float	101.00 
		.float	 75.00 
		.float	 89.00 
		.float	 76.00 
		.float	 34.00 
		.float	 71.00 
		.float	  0.00 
		.float	 58.00 
		.float	 92.00 
		.float	 68.00 
		.float	 70.00 
		.float	 57.00 
		.float	 44.00 
		.float	 39.00 
		.float	 79.00 
		.float	 88.00 
		.float	 74.00 
		.float	 16.00 
		.float	  3.00 
		.float	  6.00 
		.float	 75.00 

		.float	 20.00 
		.float	 68.00 
		.float	 77.00 
		.float	 62.00 
		.float	  0.00 
		.float	  0.00 
		.float	 33.00 
		.float	 28.00 
		.float	 72.00 
		.float	 94.00 
		.float	 19.00 
		.float	 37.00 
		.float	 73.00 
		.float	 96.00 
		.float	 71.00 
		.float	 34.00 
		.float	 97.00 
		.float	 20.00 
		.float	 17.00 
		.float	 55.00 
		.float	 91.00 
		.float	 74.00 
		.float	 99.00 
		.float	 21.00 

		.float	 43.00 
		.float	 77.00 
		.float	 95.00 
		.float	 60.00 
		.float	 81.00 
		.float	102.00 
		.float	 25.00 
		.float	101.00 
		.float	 60.00 
		.float	102.00 
		.float	 54.00 
		.float	 60.00 
		.float	103.00 
		.float	 87.00 
		.float	 89.00 
		.float	 65.00 
		.float	 72.00 
		.float	109.00 
		.float	102.00 
		.float	 35.00 
		.float	 96.00 
		.float	 64.00 
		.float	 70.00 
		.float	 83.00 

		.float	 85.00 
		.float	 87.00 
		.float	 28.00 
		.float	 66.00 
		.float	 51.00 
		.float	 18.00 
		.float	 87.00 
		.float	 95.00 
		.float	 96.00 
		.float	 73.00 
		.float	 45.00 
		.float	 67.00 
		.float	 65.00 
		.float	 71.00 
		.float	 59.00 
		.float	 16.00 
		.float	 63.00 
		.float	  3.00 
		.float	 77.00 
		.float	 56.00 
		.float	 91.00 
		.float	 56.00 
		.float	 12.00 
		.float	 53.00 

		.float	 56.00 
		.float	  5.00 
		.float	 89.00 
		.float	 42.00 
		.float	 70.00 
		.float	 49.00 
		.float	 15.00 
		.float	 45.00 
		.float	 27.00 
		.float	 44.00 
		.float	  1.00 
		.float	 78.00 
		.float	 63.00 
		.float	 89.00 
		.float	 64.00 
		.float	 49.00 
		.float	 52.00 
		.float	109.00 
		.float	  6.00 
		.float	  8.00 
		.float	 70.00 
		.float	 65.00 
		.float	 24.00 
		.float	 24.00 

### End of data segment



