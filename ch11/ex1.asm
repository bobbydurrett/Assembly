; Template for main program.
; x86-64 nasm linux

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
extern scanf

segment .data

scanf_fmt db "%lf %ld"           ; read x and num_terms as double and long
num_terms dq 0

segment .text

main:	                         
    push rbp                     
    mov rbp,rsp                  
.read_again:
    lea rdi,[scanf_fmt]          ; read a number
    lea rdx,[num_terms]          ; read num_terms
    mov eax,eax                  ; no floating point args
    call scanf                   ; read a line, x in xmm0
    cmp eax,2                    ; check for 2 return arguments
    jne .done                    ; done if 2 values not read
; call sin function here
    jmp .read_again
.done:
    xor rax,rax                  ; return code 0
    leave                        ; fix stack
    ret                          ; return
