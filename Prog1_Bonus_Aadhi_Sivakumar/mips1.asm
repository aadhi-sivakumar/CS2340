# Programming Assignment 1
# Author: Aadhi Sivakumar
# Date: 08-28-2024
# Description: This program prompts and stores the user's name, 2 integers (a and b), 
# and the user's favorite sport. The program then displays a greeting that addresses 
# the user by their name. It then states their 2 integers they chise and calculates the score for their favorite sport.

.include "SysCalls.asm"

.data
    name: .space 256 # Reserves 256 bytes for the user's name
    promptName: .asciiz "Enter your name: "
    promptA: .asciiz "Enter one integer from 1-50: "
    promptB: .asciiz "Enter one integer fom 1-50: "
    promptSport: .asciiz "Enter your favorite sport: "
    sport: .space 256 # Reserves 256 bytes for the user's favorite sport
    greetingsMessage: .asciiz "Greetings "
    intMessage: .asciiz "I see that you have entered the integers "
    scoreMessage: .asciiz "\nBased on your input the score for the "
    gameStr: .asciiz " game will be "     
    spaceStr: .asciiz " "
    toStr: .asciiz " to "
    
.text
    # Prompt for the user's name
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code 
    la $a0, promptName            # Load address of promptName string
    syscall                       # Syscall to print promptName string

    li $v0, SysReadString         # Set $v0 to SysPrintString syscall code 
    la $a0, name                  # Load address of name
    li $a1, 256                   # Maximum length of input
    syscall                       # Syscall to read name string

    # Prompt for integer a
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code 
    la $a0, promptA               # Load address promptA string
    syscall                       # Syscall to print promptA string

    li $v0, SysReadInt            # Set $v0 to SysPrintInt syscall code 
    syscall                       # Syscall to read integer(a)
    move $t0, $v0                 # Move the integer(a) in $t0

    # Prompt for integer b   
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code 
    la $a0, promptB               # Load address of promptB string
    syscall                       # Syscall to print promptB string

    li $v0, SysReadInt            # Set $v0 to SysPrintInt syscall code 
    syscall                       # Syscall to read integer(b)
    move $t1, $v0                 # Move integer(b) in $t1 

    # Prompt for the user's favorite sport
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code 
    la $a0, promptSport           # Load ddress promptSport string
    syscall                       # Syscall to print promptSport string

    li $v0, SysReadString         # Set $v0 to SysPrintString syscall code 
    la $a0, sport                 # Load address of sport string
    li $a1, 256                   # Maximum length of input
    syscall                       # Syscall to read sport string

    # Remove the newline character from the sport string
    la $t4, sport                 # Load sport string
    li $t5, 0x0A                  # Loading the hexademcimal value for the newline character '\n'

remove_newline:
    lb $t6, 0($t4)                # Load byte from sport string
    beq $t6, $zero, end_condition    # If null character, end loop
    beq $t6, $t5, replace_null    # If newline, replace with null
    addi $t4, $t4, 1              # Move to the next character
    j remove_newline              # Repeat loop

replace_null:
    sb $zero, 0($t4)              # Replace newline with null
    j end_condition               # Exit loop

end_condition:

    # Calculate ans1 = 3a - 2b + 32
    move $t2, $t0                 # $t2 = a
    add $t2, $t2, $t0             # $t2 = a + a
    add $t2, $t2, $t0             # $t2 = 3a
    sub $t2, $t2, $t1             # $t2 = 3a - b
    sub $t2, $t2, $t1             # $t2 = 3a - 2b
    addi $t2, $t2, 32             # $t2 = 3a - 2b + 32

    # Calculate ans2 = 2b - a - 12
    move $t3, $t1                 # $t3 = b
    add $t3, $t3, $t1             # $t3 = 2b
    sub $t3, $t3, $t0             # $t3 = 2b - a
    addi $t3, $t3, -12            # $t3 = 2b - a - 12

    # Output display
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code
    la $a0, greetingsMessage      # Load address of greetingsMessage string
    syscall                       # Syscall to print greetingsMessage string

    la $a0, name                  # Load address of name
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code
    syscall                       # Syscall to print name string

    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code
    la $a0, intMessage            # Load address of intMessage string
    syscall                       # Syscall to print intMessage string

    move $a0, $t0                 # Move integer(a) for printing
    li $v0, SysPrintInt           # Set $v0 to SysPrintInt syscall code
    syscall                       # Syscall to print integer(a)

    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code 
    la $a0, spaceStr              # Load space string
    syscall                       # Syscall to print spaceStr

    move $a0, $t1                 # Move integer(b) for printing
    li $v0, SysPrintInt           # Set $v0 to SysPrintInt syscall code
    syscall                       # Syscall to print integer(b)

    li $v0,SysPrintString         # Set $v0 to SysPrintString syscall code
    la $a0, scoreMessage          # Load address scoreMessage string
    syscall                       # Syscall to print scoreMessage string

    la $a0, sport                 # Load address of sport
    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code
    syscall                       # Syscall to print sport string

    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code
    la $a0, gameStr               # Load address of gameStr string
    syscall                       # Syscall to print gameStr string

    move $a0, $t2                 # Move ans1 for printing
    li $v0, SysPrintInt           # Set $v0 to SysPrintInt syscall code
    syscall                       # Syscall to print ans1

    li $v0, SysPrintString        # Set $v0 to SysPrintString syscall code
    la $a0, toStr                 # Load toStr string
    syscall                       # Print toStr String

    move $a0, $t3                 # Move ans2 for printing
    li $v0, SysPrintInt           # Set $v0 to SysPrintInt syscall code
    syscall                       # Syscall to print ans2

    # Exit program
    li $v0, SysExit               # Set $v0 to SysExit syscall code
    syscall                       # Syscall to exit
