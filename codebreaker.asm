main: 
////prompting the user
//prompt codemaker
      MOV R2,#prompt_codemaker
      STR R2,.WriteString
      MOV R0,#name_codemaker 
      STR R0,.ReadString
//prompt codebreaker
      MOV R2,#prompt_codebreaker
      STR R2,.WriteString
      MOV R0,#name_codebreaker
      STR R0,.ReadString
//prompt maximum guesses
      MOV R2,#prompt_guesses
      STR R2,.WriteString
      LDR R0,.InputNum
      STR R0,Maximum_guesses
////printing the names
      MOV R2,#line
      STR R2,.WriteString
//code maker
      MOV R1,#0x0A
      STRB R1,.WriteChar // "/n"
      MOV R2,#code_makeris
      STR R2,.WriteString
      MOV R2,#name_codemaker
      STR R2,.WriteString
//code breaker  
      MOV R2,#code_breakeris
      STR R2,.WriteString
      MOV R2,#name_codebreaker
      STR R2,.WriteString
//maximum guesses
      MOV R2,#Maximum_guessesis
      STR R2,.WriteString
      ldr R2,Maximum_guesses
      STR R0,.WriteSignedNum 
      MOV R2,#line
      STR R2,.WriteString
////Getting code from code maker
      MOV R1,#0x0A
      STRB R1,.WriteChar // "/n" 
      MOV R2,#name_codemaker
      STR R2,.WriteString
      MOV R2,#code_maker_prompt
      STR R2,.WriteString
      MOV R0,#secret_code
      bl get_code
      mov R12, #Maximum_guesses //R12 have the maximum guesses
      ldr R12, [R12]
////loop and ask code breaker to guess the game untill he wins or his guesses ends
guess_loop:
      cmp R12, #0
      beq print_lose
//print the first line for information 
      MOV R2,#line
      STR R2,.WriteString
      MOV R1,#0x0A
      STRB R1,.WriteChar // "/n" 
      MOV R2,#name_codebreaker
      STR R2,.WriteString
      MOV R2,#code_breaker_prompt
      STR R2,.WriteString
      MOV R0,R12
      STR R0,.WriteSignedNum
      mov R0,#query_code
      bl get_code
      mov R9,#query_code
      mov R10,#secret_code
      bl comparecodes
//printing the results
      MOV R2,#position_matched
      STR R2,.WriteString
      STR R0,.WriteSignedNum 
      MOV R2,#colour_matched
      STR R2,.WriteString
      STR R1,.WriteSignedNum 
//if R0 = 4 => all positions match 		  
      cmp R0,#4
      beq print_win
      sub R12,R12,#1    //decrement the guesses
      b guess_loop
print_win: 
      MOV R1,#0x0A
      STRB R1,.WriteChar // "/n"
      MOV R2,#name_codebreaker
      STR R2,.WriteString
      MOV R2,#win
      STR R2,.WriteString
      HALT 
print_lose:
      MOV R1,#0x0A
      STRB R1,.WriteChar // "/n"
      MOV R2,#name_codebreaker
      STR R2,.WriteString
      MOV R2,#lose
      STR R2,.WriteString
      HALT
comparecodes:
//input: R9 = qeurycode, R10= secret code
//output: R6 <<= case 1, R7 <<= case 2
//trashes: R0,R1,R2,R3,R4,R5
      mov R0,#0
      mov R1,#0
      mov R3,#0         //counter main
loop_main_compare:
      mov R2,#0         //counter nested
loop_nested_compare:
//increment nested loop counter
      ldrb R4,[R9+R3]
      ldrb R5,[R10+R2]
      cmp R4,R5         //if secret[i] != secret[j] : pass (check next charecter) 
      bne next 
//secret[i] == secret[j]
      cmp R2,R3         //i==j: case1++  : pass (check next charecter)         
      beq case1 
      add R1,R1,#1      //case 2++
      mov R2,#4         //break the compare of that value
      b next
case1:
      add R0,R0,#1
      mov R2,#4         //break the compare of that value
next:
      add R2,R2,#1      //increment
      cmp R2,#4
      blt loop_nested_compare
      add R3,R3,#1      //increment
      cmp R3,#4
      blt loop_main_compare
      ret
get_code:
//Input: R0 => array to store the input   
//output: filles the buffer in R0, with a valid input
//trashes:R1,R2,R3
      MOV R2,#prompt_code
      STR R2,.WriteString
      STR R0,.ReadString //r0 have the buffer
      mov R1,#0         //counter
      mov R2,R0         //poiter to buffer
loop_validation:
      ldrb R3,[R2+R1]
      cmp R3,#114       //r
      beq next_charecter
      cmp R3,#103       //g
      beq next_charecter
      cmp R3,#98        //b
      beq next_charecter
      cmp R3,#121       //y
      beq next_charecter
      cmp R3,#112       //p
      beq next_charecter
      cmp R3,#99        //c
      beq next_charecter
//if no branchtaken its an error
      MOV R2,#line
      STR R2,.WriteString 
      MOV R2,#err1
      STR R2,.WriteString
      MOV R2,#line
      STR R2,.WriteString
      b get_code
next_charecter:
      add R1,R1,#1      //increment
      cmp R1,#4
      blt loop_validation
      ret
//data area
      .data
//formating tex
line: .ASCIZ "\n----------------------------"
//prompt messages
prompt_codemaker: .ASCIZ "Codemaker's name:  "
prompt_codebreaker:.ASCIZ "\nCodebreaker's name: "
prompt_guesses:.ASCIZ "\nMaximum guesses allowed: "
prompt_code:.ASCIZ "\nEnter a code: "
//input buffers
name_codemaker: .BLOCK 128
name_codebreaker: .BLOCK 128
Maximum_guesses: .WORD 0
secret_code: .BLOCK 4
query_code: .BLOCK 4
//output messages
code_makeris: .ASCIZ "\nCodemaker is "
code_breakeris: .ASCIZ "\nCodebreaker is "
Maximum_guessesis: .ASCIZ "\nMaximum number of guesses: "
code_maker_prompt: .ASCIZ ", please enter a 4-char secret code. "
code_breaker_prompt: .ASCIZ ", this is guess number: "
position_matched: .ASCIZ "\nPosition matches:  "
colour_matched: .ASCIZ ",colour matches:  "
lose: .ASCIZ ", you LOSE!"
win:  .ASCIZ ", you WIN!"
//error messages
err1: .ASCIZ "\nWrong Code! possible colours: r,g,b,y,p,c"
