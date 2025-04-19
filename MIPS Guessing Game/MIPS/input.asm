.data
    prompt: .asciiz "Pick a card index (0-15): "
    error_msg: .asciiz "Invalid input. Please enter a number between 0 and 15.\n"
    revealed_error: .asciiz "This card is already revealed. Please choose another.\n"

.text
.globl get_user_input

get_user_input:
    # Save return address
    addi $sp, $sp, -4
    sw $ra, 0($sp)

input_loop:
    li $v0, 4
    la $a0, prompt
    syscall

    li $v0, 5  # Read integer
    syscall

    # Validate input range
    bltz $v0, input_error
    bgt $v0, 15, input_error

    # Check if the card is already revealed
    la $t0, card_state
    add $t1, $t0, $v0
    lb $t2, ($t1)
    bnez $t2, card_revealed_error

    # Input is valid and card is not revealed
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

input_error:
    li $v0, 4
    la $a0, error_msg
    syscall
    j input_loop

card_revealed_error:
    li $v0, 4
    la $a0, revealed_error
    syscall
    j input_loop
