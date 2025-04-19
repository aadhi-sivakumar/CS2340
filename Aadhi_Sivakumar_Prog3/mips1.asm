# Programming Assignment 3
# Author: Aadhi Sivakumar
# Date: 10-14-2024
# Description: This program reads a file called "input.txt" line 
# by line. It allows the user to enter values for X and Y and 
# terminates if the user enters 0 for either X or Y or if 
# X > Y. It then gives the the cumulative sum of the integers 
# squared between X and Y twice - once by the iterative procedure 
# and the other by the recursive procedure. 

.include "SysCalls.asm"

.data
    filename: .asciiz "/Users/aadhithyasivakumar/Documents/CS2340/Aadhi_Sivakumar_Prog3/input.txt"  # File to open
    buffer: .space 256                                                                              # Buffer to store file content
    str1: .asciiz "Give me a number between 1 and 100 (Type 0 to stop): "
    str2: .asciiz "Give me a second number between\n"                                               # Before displaying X
    str3: .asciiz " and 100 (Type 0 to stop): "                                                     # After displaying X
    str4: .asciiz "Adding squares from\n"                                                           # Before displaying "X"
    str5: .asciiz " to "                                                                            # In between displaying "X" and "Y"
    str6: .asciiz "\nITERATIVE: "                                                                   # Label for iterative sum output
    str7: .asciiz "\nRECURSIVE: "                                                                   # Label for recursive sum output

.text

    li $v0, SysOpenFile       # Syscall for open file
    la $a0, filename          # File name
    li $a1, 0                 # Read-only mode
    syscall
    move $t0, $v0             # Store file descriptor

    li $v0, SysReadFile       # Syscall for read file
    move $a0, $t0             # File descriptor
    la $a1, buffer            # Buffer to store file content
    li $a2, 256               # Number of bytes to read
    syscall

    li $v0, SysCloseFile      # Syscall for close file
    move $a0, $t0             # File descriptor
    syscall

    # Loop for prompting user input
    j prompt_user              # Jump to prompt_user

# Procedure to prompt user for input with dynamic X and Y values
prompt_user:
    # Load and print first prompt
    la $a0, str1
    li $v0, SysPrintString     # Syscall for printing a string
    syscall

    # Read integer X
    li $v0, SysReadInt         # Syscall for reading an integer
    syscall
    move $t1, $v0             # Store X in $t1

    # Check if X is 0, then exit
    beqz $t1, exit_program     # If X is 0, jump to exit

    # Print second prompt, dynamically inserting X before "and 100"
    la $a0, str2
    li $v0, SysPrintString     # Print the prefix
    syscall

    move $a0, $t1              # Print X value
    li $v0, SysPrintInt        # Syscall for printing an integer
    syscall

    la $a0, str3
    li $v0, SysPrintString     # Print the suffix
    syscall

    # Read integer Y
    li $v0, SysReadInt         # Syscall for reading an integer
    syscall
    move $t2, $v0              # Store Y in $t2

    # Check if X > Y or if either is 0, then exit
    bgt $t1, $t2, exit_program
    beqz $t2, exit_program

    # Print the range "Adding squares from X to Y"
    la $a0, str4
    li $v0, SysPrintString     # Print the prefix
    syscall

    move $a0, $t1              # Print X value
    li $v0, SysPrintInt        # Print X as an integer
    syscall

    la $a0, str5
    li $v0, SysPrintString     # Print the middle part
    syscall

    move $a0, $t2              # Print Y value
    li $v0, SysPrintInt        # Print Y as an integer
    syscall

    # Iterative sum
    la $a0, str6
    li $v0, SysPrintString     # Syscall for printing a string
    syscall
    jal itr_sumsq

    # Recursive sum
    la $a0, str7
    li $v0, SysPrintString     # Syscall for printing a string
    syscall
    move $a0, $t1              # Current number (X)
    move $a1, $t2              # Target number (Y)
    # Initialize the registers for the recursive calculation
    move $t6, $t1       # Start from X for recursion
    li $t7, 0           # Initialize cumulative sum to zero
    # Call the recursive sum of squares
    jal rec_sumsq       # Execute the recursive sum function
    
    # Add two new lines
    li $v0, SysPrintChar       # Syscall for printing a character
    li $a0, 10                 # ASCII for newline
    syscall
    syscall                     # Call it again to print the second newline
  
    
    # After processing, prompt the user again
    j prompt_user              # Jump back to prompt_user

exit_program:
    li $v0, SysExit            # Syscall to exit program
    syscall

# Iterative calculation of square sums with cumulative output
itr_sumsq:
    move $t3, $t1              # Start from X
    move $t4, $zero            # Cumulative sum

  itr_loop:
    mul $t5, $t3, $t3          # Square of current number
    add $t4, $t4, $t5          # Add to cumulative sum
    move $a0, $t4              # Print current cumulative sum
    li $v0, SysPrintInt        # Syscall for printing an integer
    syscall

    # Space after each cumulative sum
    li $v0, SysPrintChar       # Print a space
    li $a0, 32                 # ASCII space
    syscall

    addi $t3, $t3, 1           # Next number in range
    ble $t3, $t2, itr_loop  # Loop until $t3 <= $t2

    jr $ra                     # Return to caller

rec_sumsq:
    # Base case: If $t6 > $t2, exit
    bgt $t6, $t2, rec_exit 

    # Calculate the square and add to cumulative sum
    mul $t8, $t6, $t6      # Calculate $t6 squared
    add $t7, $t7, $t8      # Update cumulative sum in $t7

    # Print the cumulative sum before the recursive call
    move $a0, $t7          # Move cumulative sum to $a0
    li $v0, SysPrintInt    # Print cumulative sum
    syscall

    # Print a space
    li $v0, SysPrintChar   # Syscall for printing a character
    li $a0, 32             # ASCII for space
    syscall

    # Save state before recursion
    addi $sp, $sp, -8      # Allocate stack space
    sw $ra, 4($sp)         # Save return address
    sw $t6, 0($sp)         # Save $t6 (current number)

    # Recursive call with incremented value
    addi $t6, $t6, 1       # Increment $t6 by 1
    jal rec_sumsq          # Recursive call

    # Restore state after recursion
    lw $t6, 0($sp)         # Restore $t6
    lw $ra, 4($sp)         # Restore $ra
    addi $sp, $sp, 8       # Deallocate stack space

rec_exit:
    jr $ra                 # Return to caller
