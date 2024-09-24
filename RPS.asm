.data
draw_message:   .asciiz "This game is a draw.\n"
win_message:    .asciiz "Congratulations, you have won!\n"
lose_message:   .asciiz "I am sorry, you have lost.\n"
rock:           .asciiz "Computer chose rock.\n"    
paper:          .asciiz "Computer chose paper.\n"     
scissors:       .asciiz "Computer chose scissors.\n"   
input_asked:    .asciiz "What do you choose, 0 (rock), 1 (paper), 2 (scissors)?\n"
input_validation:   .asciiz "Please pick a correct input, try again.\n"
play_again_message: .asciiz "Do you want to play again? 1 (Yes), 2 (No)?\n"
game_over_message: .asciiz "Game over!\n"
seed:           .word 12345

.text

main:
    jal    reset_seed            # Reset seed at the start of the game
    j      game_loop

game_loop:
    la     $a0, input_asked 
    li     $v0, 4
    syscall

    li     $v0, 5
    syscall  
    move   $t0, $v0 
           
    jal    random_number
    move   $t1, $v0           

    sub    $t2, $t0, $t1

    li     $t7, 0
    blt    $t2, $t7, absoluteVal

    j      calculate_winner

random_number:
    # Load the seed value
    la     $t3, seed
    lw     $t3, 0($t3)

    # Linear Congruential Generator (LCG) formula: seed = (seed * 1664525 + 1013904223)
    li     $t4, 1664525        # Multiplier
    li     $t5, 1013904223     # Increment
    mul    $t3, $t3, $t4       # seed * multiplier
    add    $t3, $t3, $t5       # seed + increment
    
    # Store the new seed value
    la     $t6, seed
    sw     $t3, 0($t6)
    
    # Mod the result by 3 to get a value between 0 and 2
    li     $t2, 3
    divu   $t3, $t2
    mfhi   $v0                 # The remainder is our random number

    jr     $ra                              

absoluteVal:
    li     $t7, -1
    mult   $t2, $t7
    mflo   $t2

    j       calculate_winner

calculate_winner:
    li     $t7, 0
    beq    $t2, $t7, draw 

    li     $t7, 2
    beq    $t2, $t7, rock_scissor

    li     $t7, 1
    beq    $t2, $t7, paper_chosen

    la     $a0, input_validation
    li     $v0, 4
    syscall

    j      game_loop

rock_scissor:
    beq    $t0, 0, user_win
    j      cpu_win

paper_chosen:
    beq    $t0, 0, cpu_win
    beq    $t0, 2, user_win
    beq    $t1, 0, user_win
    j      cpu_win

draw:
    la     $a0, draw_message
    li     $v0, 4
    syscall
    j      final

user_win:
    la     $a0, win_message
    li     $v0, 4
    syscall
    j      final
    
cpu_win:
    la     $a0, lose_message
    li     $v0, 4
    syscall
    j      final

final:
    la     $a0, play_again_message
    li     $v0, 4
    syscall

    li     $v0, 5
    syscall

    beq    $v0, 1, reset_seed_and_restart
    
    beq    $v0, 2, game_over
        
    j      final

reset_seed_and_restart:
    jal    reset_seed            # Reset seed when restarting the game
    j      game_loop

reset_seed:
    li     $t3, 12345            # Load the initial seed value
    la     $t4, seed
    sw     $t3, 0($t4)           # Store the initial seed value back to seed
    jr     $ra                   # Return to the caller

game_over:
    la     $a0, game_over_message
    li     $v0, 4
    syscall

    li     $v0, 10
    syscall
