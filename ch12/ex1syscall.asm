; copy from file to new file
; syscall version
; command line arguments:
; from file
; to file
; buffer size

; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax and rdx are the integer return registers
; xmm0 and xmm1 are the float return resgisters
; http://www.nasm.us/links/unix64abi

global main                      

segment .data

from_ptr dq 0
to_ptr dq 0
bufsizestrptr dq 0

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  

; Argc and argv are in rdi and rsi
; Argc is number of arguments including name of program
; Argv is array of 8 byte pointers to strings

    cmp rdi,4                    ; expect 3 arguments plus program name which we ignor
    jne .exitbadarguments
    mov qword rax, qword [rsi+8]
    mov qword [from_ptr],rax
    mov qword rax, qword [rsi+16]
    mov qword [to_ptr],rax
    mov qword rax, qword [rsi+24]
    mov qword [bufsizestrptr],rax
    
.exitbadarguments:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
