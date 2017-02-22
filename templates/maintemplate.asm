; Template for main program.
; x86-64 nasm linux

           segment .data
abcdeabcde dq 0                       ; ten character variable names
           segment .text
main:
           push rbp                   ; opcodes start column 12
           mov rbp,rsp                ; comments from 39 to 79 ................

; Argc and argv are in rdi and rsi
; Argc is number of arguments including name of program
; Argv is array of 8 byte pointers to strings

; My code goes here

           xor eax,eax                ; return code 0
           leave                      ; fix stack
           ret                        ; return
