; Swap two quad words using xor.
; a = a ^ b
; b = a ^ b
; a = a ^ b
    section .data
a      dq 123             
b      dq 567
       section .text
       global start
start:
       mov rax,[a]  ; Load a into rax
       mov rbx,[b]  ; Load b into rbx
       xor rax,rbx  ; a = a ^ b
       xor rbx,rax  ; b = a ^ b
       xor rax,rbx  ; a = a ^ b
       mov [a],rax  ; Return a to memory
       mov [b],rbx  ; Return b to memory
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
