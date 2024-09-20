# Programming Assignment 2
# Author: Aadhi Sivakumar
# Date: 09-19-2024
# Description: This program prompts for X (the array size) and Y (the maxium value for the array). 
# It then generates a random array of size X where the values cannot be more than Y.
# Next, it sorts the array from least to greatest using bubble sort and rearranges
# the sorted array where the maximum values are in the even indices decending and 
# the smallest values are in the odd indices accending. Lastly, it displays all the array
# (original, sorted, and rearranged). 


.include "SysCalls.asm"

.data
    promptX:            .asciiz "Enter a number from 2-50: "              # Prompt for X input (Array Size)
    promptY:            .asciiz "Enter a number from 2-50: "              # Prompt for Y input (Maximum Value for Array)
    errorMsg:           .asciiz "Invalid input. Exiting program.\n"       # Message for exiting the program if X and Y are not between 2 and 50
    originalArrayMsg:   .asciiz "Before: "                                # Message for displaying the original randomly generated array
    sortedArrayMsg:     .asciiz "\nAfter Sort: "                          # Message for displaying the sorted array from least to greatest 
    rearrangedArrayMsg: .asciiz "\nAfter Rearrange: "                     # Message for displaying the rearranged array
    blank:              .asciiz " "                                       # Blank space for formatting the numbers

.text 
    # Prompt and get input X
    li $v0, SysPrintString   # Load the system call for printing a string
    la $a0, promptX          # Load the prompt message for X
    syscall                  # Print the prompt for X

    li $v0, SysReadInt       # Load the system call reading an integer
    syscall                  # Read the user's input for X
    move $t0, $v0            # Store X in $t0

    # Validate X
    blt $t0, 2, invalid_input   # If X < 2, jump to invalid_input
    bgt $t0, 50, invalid_input  # If X > 50, jump to invalid_input

    # Prompt and get input Y
    li $v0, SysPrintString   # Load the system call for printing a string
    la $a0, promptY          # Load the prompt message for Y   
    syscall                  # Print the prompt for Y

    li $v0, SysReadInt       # Load the system call reading an integer
    syscall                  # Read the user's input for Y
    move $t1, $v0            # Store Y

    # Validate Y
    blt $t1, 2, invalid_input   # If X < 2, jump to invalid_input
    bgt $t1, 50, invalid_input  # If X > 50, jump to invalid_input

    # Allocate memory for array
    li $v0, SysAlloc    # Load the system call for memory allocation 
    mul $a0, $t0, 4     # Allocate X * 4 bytes
    syscall             # Allocate the memory
    move $s0, $v0       # Store the base address of array in $s0
    move $s1, $s0       # Copy the base address in $s1 for later
    move $s6, $t0       # Store the size of the array in $s6

    # Generate random array
    li $t2, 0  # Initializing the index for the loop
generate_random:
    bge $t2, $t0, display_original_array  # If index >= X, jump to displaying the original array
    li $v0, SysRandIntRange               # Load the system call for generating random numbers 
    move $a1, $t1                         # Set Y as the upper bound for random values
    syscall                               # Generate a random number
    sw $a0, 0($s0)                        # Store random number in array
    addi $s0, $s0, 4                      # Move to the next array element
    addi $t2, $t2, 1                      # Increment the index by 1
    j generate_random                     # Loop back to generate the next number in the array
 
# Display original array
display_original_array:
    li $v0, SysPrintString     # Load the system call for printing a string        
    la $a0, originalArrayMsg   # Load the message for the original array
    syscall                    # Print the original array message

    move $s0, $s1              # Restore base address
    li $t2, 0                  # Reset index
    
print_original_loop:
    bge $t2, $t0, start_sorting  # If index >= X, jump to start_sorting
    lw $a0, 0($s0)               # Load array element
    li $v0, 1                    # SysPrintInt
    syscall
    li $v0, SysPrintString
    la $a0, blank                # Print space
    syscall
    addi $s0, $s0, 4             # Next array slot
    addi $t2, $t2, 1
    j print_original_loop        # Loop to print next array element

# Sorting the array using Bubble Sort
start_sorting:
    move $s0, $s1  # Restore base address
    li $t2, 0      # Outer loop index

outer_sort_loop:
    addi $t3, $t0, -1               # Set upper bound for inner loop
    sub $t3, $t3, $t2               # Calculate remaining unsorted portion
    blez $t3, display_sorted_array  # Exit when sorted

    li $t4, 0  # Inner loop index
inner_sort_loop:
    bge $t4, $t3, next_outer_loop  # If inner index >= bound, exit inner loop

    # Compare values and swap if needed
    sll $t5, $t4, 2    # Calculate offset (index * 4)
    add $t6, $s1, $t5  # Address of arr[j]
    lw $t7, 0($t6)     # Load arr[j]
    lw $t8, 4($t6)     # Load arr[j+1]

    slt $t9, $t8, $t7               # Compare arr[j+1] < arr[j]
    beq $t9, $zero, continue_inner  # Skip swap if in order

    # Swap arr[j] and arr[j+1]
    sw $t8, 0($t6)  # Store arr[j+1] in arr[j]
    sw $t7, 4($t6)  # Store arr[j] in arr[j+1]

continue_inner:
    addi $t4, $t4, 1  # Increment inner index
    j inner_sort_loop # Jump to inner_sort_loop

next_outer_loop:
    addi $t2, $t2, 1   # Increment outer index
    j outer_sort_loop  # Jump to outer_sort_loop

# Display sorted array
display_sorted_array:
    li $v0, SysPrintString   # Load the system call for printing a string
    la $a0, sortedArrayMsg   # Load the message for the sorted array
    syscall                  # Print the sorted array message

    move $s0, $s1            # Restore base address
    li $t2, 0                # Reset index
print_sorted_loop:
    bge $t2, $t0, start_rearranging  # If index >= X, done
    lw $a0, 0($s0)                   # Load array element
    li $v0, SysPrintInt              # Load SysPrintInt 
    syscall
    li $v0, SysPrintString
    la $a0, blank                    # Print space
    syscall
    addi $s0, $s0, 4                 # Next array slot
    addi $t2, $t2, 1
    j print_sorted_loop              # Loop to next array element

# Rearrange array: largest elements in even positions, smallest in odd
start_rearranging:
    # Restore the array base pointer before displaying sorted array
    move $s0, $s1

    li $v0, SysPrintString       # Load the system call for printing a string
    la $a0, rearrangedArrayMsg   # Load the message for the rearranged array
    syscall                      # Print the rearranged array message

    li $t2, 0  # Index

    # Create two pointers: one for the largest elements and one for the smallest
    move $t3, $zero       # Pointer for smallest elements 
    sub $t4, $t0, 1       # Pointer for largest elements 

    # Temporary array to store rearranged values
    li $v0, SysAlloc  # Memory allocation
    mul $a0, $t0, 4  # Allocate space for X elements (4 bytes per integer)
    syscall
    move $s2, $v0    # Base address of temporary array

rearrange_loop:
    bge $t2, $t0, display_rearranged  # If index >= size of array, jump to display_rearranged

    # If the index is even, pick from the largest elements (descending)
    andi $t5, $t2, 1                   # Check if index is even (t5 = t2 % 2)
    beq $t5, $zero, even_index

# If the index is odd, pick from the smallest elements (ascending)
odd_index:
    sll $t6, $t3, 2      # Calculate offset for smallest elements
    add $t6, $t6, $s1    # Add base address of sorted array
    lw $t7, 0($t6)       # Load smallest element
    sw $t7, 0($s2)       # Store in rearranged array
    addi $t3, $t3, 1     # Increment pointer for smallest elements
    j next_element       # Jump to next_element

even_index:
    sll $t6, $t4, 2      # Calculate offset for largest elements
    add $t6, $t6, $s1    # Add base address of sorted array
    lw $t7, 0($t6)       # Load largest element
    sw $t7, 0($s2)       # Store in rearranged array
    addi $t4, $t4, -1    # Decrement pointer for largest elements

next_element:
    addi $s2, $s2, 4     # Move to next element in rearranged array
    addi $t2, $t2, 1     # Increment index
    j rearrange_loop     # Jump to rearrange_loop

display_rearranged:
    # Restore base pointer of rearranged array to start
    mul $t5, $s6, 4     # Calculate total bytes moved
    sub $s2, $s2, $t5   # Restore the temporary array base address

    li $t2, 0           # Reset index for displaying rearranged array
    move $s0, $s2       # Point $s0 to the rearranged array

display_rearranged_loop:
    bge $t2, $t0, exit  # If index >= size of array, exit

    lw $a0, 0($s0)      # Load element from rearranged array
    li $v0, SysPrintInt # Load SysPrintInt
    syscall              

    li $v0, SysPrintString
    la $a0, blank       # Print a space for formatting
    syscall

    addi $s0, $s0, 4    # Move to next element
    addi $t2, $t2, 1    # Increment index
    j display_rearranged_loop # Loop again for next number to be displayed

exit:
    li $v0, SysExit  # Exit program
    syscall

# Invalid input handling
invalid_input:
    li $v0, SysPrintString
    la $a0, errorMsg
    syscall
    li $v0, SysExit  # Exit program
    syscall
