; Template for function.
; x86-64 nasm linux
; Non-float arguments in these registers:
; rdi, rsi, rdx, rcx, r8 and r9
; rax contains the number of floating point arguments
; xmm0 to xmm7 contain the float arguments
; These registers must be preserved across function calls:
; rbx, rsp, rbp, r12-r15
; rax is the return register
; https://software.intel.com/sites/default/files/article/402129/mpx-linux64-abi.pdf

myfunction:
           push rbp                   ; opcodes start column 12
           mov rbp,rsp                ; comments from 39 to 79 ................

; My code goes here

           leave                      ; fix stack
           ret                        ; return
