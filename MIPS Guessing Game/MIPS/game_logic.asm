.text
.globl check_match, is_board_complete

check_match:
    # Save return address and $s registers
    addi $sp, $sp, -16
    sw $ra, 12($sp)
    sw $s0, 8($sp)
    sw $s1, 4($sp)
    sw $s2, 0($sp)

    # Load board addresses
    la $t0, board
    lw $t7, board_size
    bge $a0, $t7, invalid_index
    bge $a1, $t7, invalid_index

    sll $t1, $a0, 2  # Multiply index by 4 (word size)
    sll $t2, $a1, 2
    add $t1, $t1, $t0
    add $t2, $t2, $t0
    
    # Load values
    lw $s0, ($t1)  # First card
    lw $s1, ($t2)  # Second card

    # Check if one is expression and other is result
    la $t5, expressions
    lw $t6, expr_count
    sll $t6, $t6, 2
    add $t6, $t5, $t6  # End of expressions array
    
    # Check if first card is an expression
    move $a0, $s0
    move $a1, $t5  # Start of expressions array
    move $a2, $t6  # End of expressions array
    jal is_expression
    move $s2, $v0  # Save result

    bnez $s2, first_is_expression

    # First card is not an expression, check second card
    move $a0, $s1
    jal is_expression
    beqz $v0, not_match  # Neither is an expression, no match

    # Second card is expression, first must be result
    move $a0, $s1  # Expression
    move $a1, $s0  # Result
    j evaluate_expression

first_is_expression:
    # First card is expression, second must be result
    move $a0, $s0  # Expression
    move $a1, $s1  # Result

evaluate_expression:
    # $a0 is expression address, $a1 is result
    jal evaluate_expression_impl
    
    # Compare result
    beq $v0, $a1, match_found

not_match:
    li $v0, 0
    j check_match_return

match_found:
    li $v0, 1

check_match_return:
    # Restore $s registers and return address
    lw $s2, 0($sp)
    lw $s1, 4($sp)
    lw $s0, 8($sp)
    lw $ra, 12($sp)
    addi $sp, $sp, 16
    jr $ra

invalid_index:
    li $v0, -1  # Return -1 for invalid index
    j check_match_return


# Helper function to check if a value is an expression
is_expression:
    move $t0, $a0  # Value to check
    move $t1, $a1  # Start of expressions array
    move $t2, $a2  # End of expressions array

is_expression_loop:
    beq $t1, $t2, not_expression  # Reached end of array
    lw $t3, ($t1)
    beq $t0, $t3, found_expression
    addi $t1, $t1, 4
    j is_expression_loop

found_expression:
    li $v0, 1
    jr $ra

not_expression:
    li $v0, 0
    jr $ra

evaluate_expression_impl:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # $a0 contains the address of the expression string
    li $t1, 0  # First number
    li $t2, 0  # Second number
    li $t3, '*'  # Multiplication symbol

    # Read first number
    lbu $t4, ($a0)
    jal char_to_digit
    bltz $v0, eval_error
    move $t1, $v0

read_first_number_loop:
    addi $a0, $a0, 1
    lbu $t4, ($a0)
    beq $t4, $t3, read_second_number
    jal char_to_digit
    bltz $v0, eval_error
    li $t5, 10
    mult $t1, $t5
    mflo $t1
    add $t1, $t1, $v0
    j read_first_number_loop

read_second_number:
    addi $a0, $a0, 1
    lbu $t4, ($a0)
    jal char_to_digit
    bltz $v0, eval_error
    move $t2, $v0

read_second_number_loop:
    addi $a0, $a0, 1
    lbu $t4, ($a0)
    beq $t4, $zero, calculate_result
    jal char_to_digit
    bltz $v0, eval_error
    li $t5, 10
    mult $t2, $t5
    mflo $t2
    add $t2, $t2, $v0
    j read_second_number_loop

calculate_result:
    mult $t1, $t2
    mflo $v0
    # Check for overflow
    mfhi $t6
    bnez $t6, eval_error
    j eval_return

eval_error:
    li $v0, -1  # Return -1 to indicate an error

eval_return:
    # Restore return address and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra
    
char_to_digit:
    addi $v0, $t4, -48  # Convert ASCII to integer
    bltz $v0, char_error
    bgt $v0, 9, char_error
    jr $ra

char_error:
    li $v0, -1  # Return -1 to indicate an error
    jr $ra

is_board_complete:
    la $t0, card_state
    lw $t2, board_size
    li $t1, 0  # Counter

complete_check_loop:
    beq $t1, $t2, board_is_complete
    lb $t3, ($t0)
    beqz $t3, not_complete
    addi $t0, $t0, 1
    addi $t1, $t1, 1
    j complete_check_loop

board_is_complete:
    li $v0, 1
    jr $ra

not_complete:
    li $v0, 0
    jr $ra
