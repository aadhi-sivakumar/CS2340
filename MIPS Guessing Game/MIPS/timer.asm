.data
    time_label: .asciiz "Time: "
    colon: .asciiz ":"
    start_time: .word 0  # Store the start time

.text
.globl update_timer, display_timer, reset_timer, get_elapsed_time, display_time_in_seconds

reset_timer:
    # Get the current system time
    li $v0, 30
    syscall
    # Store the start time
    sw $a0, start_time
    jr $ra

update_timer:
    # Get the current system time
    li $v0, 30
    syscall
    # Calculate elapsed time
    lw $t0, start_time
    subu $v0, $a0, $t0  # $v0 now contains elapsed time in milliseconds
    # Convert to seconds
    li $t1, 1000
    divu $v0, $t1
    mflo $v0  # $v0 now contains elapsed time in seconds
    jr $ra

get_elapsed_time:
    # This is now the same as update_timer
    j update_timer

display_time_in_seconds:
    # Save $ra on the stack
    addi $sp, $sp, -4
    sw $ra, 0($sp)

    # $a0 contains the time in seconds
    move $t0, $a0
    
    # Calculate minutes and seconds
    li $t1, 60
    div $t0, $t1
    mflo $t2  # minutes
    mfhi $t3  # seconds
    
    # Print minutes
    move $a0, $t2
    jal print_two_digits
    
    # Print colon
    li $v0, 4
    la $a0, colon
    syscall
    
    # Print seconds
    move $a0, $t3
    jal print_two_digits
    
    # Print newline
    li $v0, 4
    la $a0, newline
    syscall
    
    # Restore $ra and return
    lw $ra, 0($sp)
    addi $sp, $sp, 4
    jr $ra

print_two_digits:
    li $t0, 10
    div $a0, $t0
    mflo $t1  # tens digit
    mfhi $t2  # ones digit

    li $v0, 1
    move $a0, $t1
    syscall

    li $v0, 1
    move $a0, $t2
    syscall

    jr $ra

display_timer:
    # This function is now obsolete, but kept for compatibility
    jr $ra
