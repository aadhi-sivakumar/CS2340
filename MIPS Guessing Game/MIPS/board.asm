.data
board: .space 64  # 16 words (4 bytes each) for 4x4 board
board_size: .word 16
card_state: .space 16  # 0 = hidden, 1 = revealed
row_separator: .asciiz "+-----+-----+-----+-----+\n"
hidden_card: .asciiz " ? "

# Bank of expressions and results
expr1: .asciiz "2*2"
expr2: .asciiz "2*3"
expr3: .asciiz "2*4"
expr4: .asciiz "2*5"
expr5: .asciiz "3*3"
expr6: .asciiz "3*4"
expr7: .asciiz "3*5"
expr8: .asciiz "4*4"

expressions: .word expr1, expr2, expr3, expr4, expr5, expr6, expr7, expr8
results: .word 4, 6, 8, 10, 9, 12, 15, 16
expr_count: .word 8  # Number of expressions/results

.text
.globl initialize_board, display_board, hide_card, reveal_card

initialize_board:
    la $t0, board            # Board base address
    li $t1, 0                # Counter for filled cards
    li $t2, 16               # Total unique cards to place (8 expressions + 8 results)
    la $t3, expressions      # Address of expressions
    la $t4, results          # Address of results

fill_board_loop:
    beq $t1, $t2, shuffle_board  # Stop when 16 cards are filled

    # Generate random index for board position
    li $v0, 42                # Syscall for random number
    li $a1, 16                # Upper bound (exclusive)
    syscall
    move $t7, $a0             # Random index in $t7

    # Check if board position is already filled
    sll $t8, $t7, 2           # Multiply by 4 for word addressing
    add $t9, $t8, $t0         # Address of board[$t7]
    lw $s0, ($t9)
    bnez $s0, fill_board_loop  # If not zero, position is filled, try again

    # Alternate between placing expressions and results
    andi $s1, $t1, 1          # Check if $t1 is even or odd
    beqz $s1, place_expression

place_result:
    lw $s2, ($t4)             # Load result
    sw $s2, ($t9)             # Store result on board
    addi $t4, $t4, 4          # Move to the next result
    j continue_fill

place_expression:
    lw $s2, ($t3)             # Load expression address
    sw $s2, ($t9)             # Store expression address on board
    addi $t3, $t3, 4          # Move to the next expression

continue_fill:
    addi $t1, $t1, 1          # Increment filled card count
    j fill_board_loop

shuffle_board:
    # Shuffle logic can be implemented here
    j init_card_state

init_card_state:
    la $t0, card_state        # Base address of card_state
    li $t1, 0                 # Counter
    li $t2, 16                # Total cards

init_state_loop:
    beq $t1, $t2, init_done
    sb $zero, ($t0)           # Set all card states to 0 (hidden)
    addi $t0, $t0, 1          # Move to next card
    addi $t1, $t1, 1          # Increment counter
    j init_state_loop

init_done:
    jr $ra

display_board:
    la $t0, board             # Base address of board
    la $t1, card_state        # Base address of card_state
    li $t2, 0                 # Row counter

display_loop:
    beq $t2, 4, display_done  # Print only 4 rows

    la $a0, row_separator
    li $v0, 4                 # Print row separator
    syscall

    li $t3, 0                 # Column counter
column_loop:
    beq $t3, 4, end_row

    # Print column separator
    li $v0, 11
    li $a0, '|'
    syscall

    li $v0, 11
    li $a0, ' '               # Print space
    syscall

    lb $t4, ($t1)             # Load card state
    beqz $t4, print_hidden    # If hidden, print '?'

    lw $t5, ($t0)             # Load board content
    li $t6, 1000              # Threshold for expressions
    blt $t5, $t6, print_result

    li $v0, 4                 # Print expression
    move $a0, $t5
    syscall
    j print_space

print_result:
    li $v0, 1                 # Print result as integer
    move $a0, $t5
    syscall
    j print_space

print_hidden:
    la $a0, hidden_card       # Print hidden card symbol
    li $v0, 4
    syscall

print_space:
    li $v0, 11
    li $a0, ' '               # Print space
    syscall

    addi $t0, $t0, 4          # Move to next board slot
    addi $t1, $t1, 1          # Move to next card state
    addi $t3, $t3, 1          # Increment column counter
    j column_loop

end_row:
    li $v0, 11
    li $a0, '|'
    syscall
    li $v0, 11
    li $a0, '\n'
    syscall

    addi $t2, $t2, 1          # Increment row counter
    j display_loop

display_done:
    la $a0, row_separator
    li $v0, 4
    syscall
    jr $ra

hide_card:
    la $t0, card_state
    add $t1, $t0, $a0
    li $t2, 0                 # Hidden state
    sb $t2, ($t1)
    jr $ra

reveal_card:
    la $t0, card_state
    add $t1, $t0, $a0
    li $t2, 1                 # Revealed state
    sb $t2, ($t1)
    jr $ra
