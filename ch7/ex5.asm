; Extract the pieces of a double float
; Fraction bits 0-51
; Exponent bits 52-62
; Sign bit 63
; Exponent bias 1023
    section .data
input  dq 0.5  
frac   dq 0
expt   dq 0
signb  dq 0
       section .text
       global start
start:
       mov rax,[input]   ; Save input in rax
       mov rbx,rax       ; Use rbx for extract
       shl rbx,12        ; Clear out the top
       shr rbx,12        ; 12 bits
       bts rbx,52        ; Set bit 52 for 1 digit
       mov [frac],rbx    ; save fraction with 1.
       mov rbx,rax       ; Use rbx for extract
       shr rbx,52        ; Shift past the fraction
       and rbx,0x7FF       ; 11 bits 
       sub rbx,1023      ; Subtract bias
       mov [expt],rbx    ; save exponent without bias
       mov rbx,rax       ; Use rbx for extract
       shr rbx,63        ; Shift to last bit
       mov [signb],rbx   ; Sign bit
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
