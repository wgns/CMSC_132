
##############################################################################
#
#  KURS: 1DT016 2014.  Computer Architecture
#	
# DATUM:
#
#  NAMN:			
#
#  NAMN:
#
##############################################################################

	.data
	
ARRAY_SIZE:
	.word	10	# Change here to try other values (less than 10)
FIBONACCI_ARRAY:
	.word	1, 1, 2, 3, 5, 8, 13, 21, 34, 55
STR_str:
	.asciiz ""
#STR_str2:
#	.asciiz "Hunden, Katten, Glassen"

	.globl DBG
	.text

##############################################################################
#
#  DESCRIPTION: For an array of integers, returns the total sum of all
#		        elements in the array.
#
#        INPUT: $a0 - address to first integer in array.
#		        $a1 - size of array, i.e., numbers of integers in the array.
#
#       OUTPUT: $v0 - the total sum of all integers in the array.
#
##############################################################################
integer_array_sum:  

DBG:	##### DEBUGG BREAKPOINT ######
	addi $v0, $zero, 0			# Initialize Sum to zero.
	add	$t0, $zero, $zero		# Initialize array index i to zero.
	
for_all_in_array: 
	beq $s0, $a1, end_for_all   # Done if i == N
	mul $s4, $s0, 4     		# 4*i
	add $s4, $a0, $s4   		# address = ARRAY + 4*i
	lw $s4, 0($s4)      		# n = A[i]
    add $v0, $v0, $s4   		# Sum = Sum + n
    addi $s0, $s0, 1    		# i++ 
    j for_all_in_array  		# return to loop 

end_for_all: 
	jr	$ra						# Return to caller.
	
##############################################################################
#
#  DESCRIPTION: Gives the length of a string.
#
#        INPUT: $a0 - address to a NUL terminated string.
#
#       OUTPUT: $v0 - length of the string (NUL excluded).
#
#      EXAMPLE: string_length("abcdef") == 6.
#
##############################################################################	
string_length:
	add $v0, $zero, $zero    # set length to zero
	add $s0, $zero, $zero    # $t1 = current character in string (i)

count:
	lb $s0, 0($a0)           # load character
	beqz $s0, str_len_end    # if character is null, end
	addi $v0, $v0, 1         # increment length
	addi $a0, $a0, 1		 # increment i
	j count
	
str_len_end:
	jr	$ra
	
##############################################################################
#
#  DESCRIPTION: For each of the characters in a string (from left to right),
#		        call a callback subroutine.
#
#		        The callback suboutine will be called with the address of
#	            the character as the input parameter ($a0).
#	
#        INPUT: $a0 - address to a NUL terminated string.
#		        $a1 - address to a callback subroutine.
#
##############################################################################	
string_for_each:
	add $s0, $a0, $zero     # copy address of string in a0 to s0

	addi $sp, $sp, -4		# PUSH return address to caller
	sw $ra, 0($sp)

str_each:
	lb $s1, 0($s0)			# load current character to s1 to check if null
	beqz $s1, str_each_end	# if yes, terminate
	add $a0, $s0, $zero     # move address of current character to a0

	jal $a1

	addi $s0, $s0, 1		# move to next character
	j str_each

str_each_end:
	lw $ra, 0($sp)			# Pop return address to caller
	addi $sp, $sp, 4		

	jr	$ra

##############################################################################
#
#  DESCRIPTION: Transforms a lower case character [a-z] to upper case [A-Z].
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################		
to_upper:
	lb $s3, 0($a0)
	blt $s3, 'a', upper_end
	bgt $s3, 'z', upper_end
	sub $s3, $s3, 32
	sb $s3, ($a0)

upper_end:
	jr $ra

##############################################################################
#
#  DESCRIPTION: Reverses a string
#
#        INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################
reverse_string:
	add $s1, $a0, $zero 	# copy address of string to $s0

	addi $sp, $sp, -4		# PUSH return address to caller
	sw $ra, 0($sp)

	jal string_length 		# get string length
	addi $v0, $v0, -1
	add $s0, $s1, $v0		# go to last character of string

	lw $ra, 0($sp)			# Pop return address to caller
	addi $sp, $sp, 4

reverse:
	lb $s2, 0($s1)			# get char (right)
	lb $s3, 0($s0)			# get char (left)

	sb $s2, ($s0)
	sb $s3, ($s1)

	addi $s1, $s1, 1
	addi $s0, $s0, -1
	blt $s0, $s1, reverse_end
	j reverse

reverse_end:
	jr $ra

##############################################################################
##
##	  You don't have to change anyghing below this line.
##	
##############################################################################
##############################################################################

	
##############################################################################
#
# Strings used by main:
#
##############################################################################

	.data

NLNL:	.asciiz "\n\n"
	
STR_sum_of_fibonacci_a:	
	.asciiz "The sum of the " 
STR_sum_of_fibonacci_b:
	.asciiz " first Fibonacci numbers is " 

STR_string_length:
	.asciiz	"\n\nstring_length(str) = "

STR_for_each_ascii:	
	.asciiz "\n\nstring_for_each(str, ascii)\n"

STR_for_each_to_upper:
	.asciiz "\n\nstring_for_each(str, to_upper)\n\n"

STR_reverse_string:
	.asciiz "\n\nreverse_string\n\n"	

	.text
	.globl main

##############################################################################
#
# MAIN: Main calls various subroutines and print out results.
#
##############################################################################	
main:
	addi	$sp, $sp, -4	# PUSH return address
	sw	$ra, 0($sp)

	##
	### integer_array_sum
	##
	
	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_a
	syscall

	lw 	$a0, ARRAY_SIZE
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, STR_sum_of_fibonacci_b
	syscall
	
	la	$a0, FIBONACCI_ARRAY
	lw	$a1, ARRAY_SIZE
	jal integer_array_sum

	# Print sum
	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	li	$v0, 4
	la	$a0, NLNL
	syscall
	
	la	$a0, STR_str
	jal	print_test_string

	##
	### string_length 
	##
	
	li	$v0, 4
	la	$a0, STR_string_length
	syscall

	la	$a0, STR_str
	jal  string_length

	add	$a0, $v0, $zero
	li	$v0, 1
	syscall

	##
	### string_for_each(string, ascii)
	##
	
	li	$v0, 4
	la	$a0, STR_for_each_ascii
	syscall
	
	la	$a0, STR_str
	la	$a1, ascii
	jal	string_for_each

	##
	### string_for_each(string, to_upper)
	##
	
	li	$v0, 4
	la	$a0, STR_for_each_to_upper
	syscall

	la	$a0, STR_str
	la	$a1, to_upper
	jal	string_for_each
	
	la	$a0, STR_str
	jal	print_test_string

	##
	### reverse_string
	##

	li	$v0, 4
	la	$a0, STR_reverse_string
	syscall

	la	$a0, STR_str
	jal	reverse_string
	
	la	$a0, STR_str
	jal	print_test_string

	lw	$ra, 0($sp)	# POP return address
	addi $sp, $sp, 4	
	
	jr	$ra

##############################################################################
#
#  DESCRIPTION : Prints out 'str = ' followed by the input string surronded
#				 by double quotes to the console. 
#
#        INPUT: $a0 - address to a NUL terminated string.
#
##############################################################################
print_test_string:	

	.data
STR_str_is:
	.asciiz "str = \""
STR_quote:
	.asciiz "\""	

	.text

	add	$t0, $a0, $zero
	
	li	$v0, 4
	la	$a0, STR_str_is
	syscall

	add	$a0, $t0, $zero
	syscall

	li	$v0, 4	
	la	$a0, STR_quote
	syscall
	
	jr	$ra
	

##############################################################################
#
#  DESCRIPTION: Prints out the Ascii value of a character.
#	
#        INPUT: $a0 - address of a character 
#
##############################################################################
ascii:	
	.data
STR_the_ascii_value_is:
	.asciiz "\nAscii('X') = "

	.text

	la	$t0, STR_the_ascii_value_is

	# Replace X with the input character
	
	add	$t1, $t0, 8	# Position of X
	lb	$t2, 0($a0)	# Get the Ascii value
	sb	$t2, 0($t1)

	# Print "The Ascii value of..."
	
	add	$a0, $t0, $zero 
	li	$v0, 4
	syscall

	# Append the Ascii value
	
	add	$a0, $t2, $zero
	li	$v0, 1
	syscall


	jr	$ra