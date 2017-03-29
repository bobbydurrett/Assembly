; Template for main program.
; x86-64 nasm linux

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return registers
; http://www.nasm.us/links/unix64abi

global main                      ; globals and externs before segments and col 1
extern stdin

; segment column 1

segment .bss

data_buffer resb 1024         

segment .data

meaningful_name dq 0             ; arbitrary length variable names

really_long_name:                ; size can start column 5 after label with :
    dq 0

segment .text

main:	                         ; labels start column 1
    push rbp                     ; opcodes start column 5
    mov rbp,rsp                  ; comments from 34 unless opcode and arguments are too long

; Argc and argv are in rdi and rsi
; Argc is number of arguments including name of program
; Argv is array of 8 byte pointers to strings

; My code goes here

    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
