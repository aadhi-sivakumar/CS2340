.include "SysCalls.asm"  
.include "board.asm"
.include "input.asm"
.include "game_logic.asm"
.include "timer.asm"

.data
    match_msg: .asciiz "It's a match!\n"
    no_match_msg: .asciiz "No match. Try again.\n"
    unmatched_cards_msg: .asciiz "Unmatched cards left: "
    time_elapsed_msg: .asciiz "Time elapsed: "
    well_done_msg: .asciiz "Well Done!\nYou finished in "
    newline: .asciiz "\n"
    unmatched_cards_count: .word 16  # Initialize with total number of cards

.text   
.globl main
main:
    # Initialize the board and game state
    jal initialize_board
    
    # Reset the timer
    jal reset_timer

    # Display the initial timer value
    li $v0, SysPrintString      # Print string syscall
    la $a0, time_elapsed_msg
    syscall

    jal update_timer
    move $a0, $v0
    jal display_time_in_seconds

main_loop:
    # Display unmatched cards count before each turn
    li $v0, SysPrintString      # Print string syscall
    la $a0, unmatched_cards_msg
    syscall

    li $v0, SysPrintInt         # Print integer syscall
    lw $a0, unmatched_cards_count
    syscall

    li $v0, SysPrintString      # Print newline
    la $a0, newline
    syscall

    # Display the current board state
    jal display_board

    # Get user input for first card index
    jal get_user_input
    move $s0, $v0  # Store first index in $s0

reveal_first_card:
    # Reveal the first selected card
    move $a0, $s0
    jal reveal_card
   
    # Display the board to show the revealed card
    jal display_board
    
    # Update and display the timer after each turn
    jal update_timer
    move $s2, $v0  # Store elapsed time in seconds

    # Display time elapsed
    li $v0, SysPrintString      # Print string syscall
    la $a0, time_elapsed_msg
    syscall

    move $a0, $s2
    jal display_time_in_seconds

    # Get user input for second card index
    jal get_user_input
    move $s1, $v0  # Store second index in $s1

reveal_second_card:
    # Reveal the second selected card
    move $a0, $s1
    jal reveal_card

    # Display the board to show the revealed card
    jal display_board

    # Update and display the timer after each turn
    jal update_timer
    move $s2, $v0  # Store elapsed time in seconds

    # Display time elapsed
    li $v0, SysPrintString      # Print string syscall
    la $a0, time_elapsed_msg
    syscall

    move $a0, $s2
    jal display_time_in_seconds

    # Check if the revealed cards match
    move $a0, $s0
    move $a1, $s1
    jal check_match
    beqz $v0, no_match
    # Cards match
    li $v0, SysPrintString      # Print string syscall
    la $a0, match_msg
    syscall
    
    # Decrease unmatched cards count by 2
    lw $t0, unmatched_cards_count
    addi $t0, $t0, -2
    sw $t0, unmatched_cards_count
    
    j continue_game

no_match:
    # Cards do not match, show message
    li $v0, SysPrintString      # Print string syscall
    la $a0, no_match_msg
    syscall

    move $a0, $s0
    jal hide_card

    move $a0, $s1
    jal hide_card

continue_game:
    # Check if the board is complete
    jal is_board_complete
    bnez $v0, board_complete

    # If not complete, go back to main_loop
    j main_loop

board_complete:
    # Board is complete
    jal display_board  # Show final board state
    
    # Get final elapsed time in seconds
    jal get_elapsed_time
    move $s0, $v0  # Save final elapsed time in $s0
    
    # Display "Well Done! You finished in "
    li $v0, SysPrintString      # Print string syscall
    la $a0, well_done_msg
    syscall

    # Format and display the elapsed time as mm:ss
    move $a0, $s0
    jal display_time_in_seconds
    
    # Print newline
    li $v0, SysPrintString      # Print string syscall
    la $a0, newline
    syscall

    # End the program
    li $v0, SysExit
    syscall
