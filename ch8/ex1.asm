; Dot product of two arrays a and b
; a[0]*b[0]+...
; answer should be 70
    section .data
a      dd 1   ; four element array a           
a1     dd 2              
a2     dd 3              
a3     dd 4              
b      dd 5   ; four element array b           
b1     dd 6              
b2     dd 7              
b3     dd 8              
n      dd 4    ; n is the number of elements in the arrays
output dq 0
       section .text
       global start
start:
       xor rax,rax          ; just added this to prevent segment fault in gdb
       mov eax,[n]          ; load n in eax
ltop:
       mov ebx,[a-4+eax*4]  ; load a[eax-1] in ebx
       mov ecx,[b-4+eax*4]  ; load b[eax-1] in ecx
       imul ebx,ecx         ; multiply a and b elements
       add [output],rbx     ; add to dot product
       dec eax
       cmp eax,0
       jg ltop
done:
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
