; Find all integers <= 500 where
; a^2 + b^2 = c^2
       segment .data
a      dq 0                   
b      dq 0                   
c      dq 0                   
maxint dq 500                                ; max value for a, b, or c 
prnfmt db "a=%ld b=%ld c=%ld",0x0a,0         ; print a, b, and c
       segment .text
       global main
       global checkabc
       extern printf
main:
       push rbp
       mov rbp,rsp
; loop through a,b,c from 1 to 500
       mov qword [a],1                       ; initialize a,b,c as 1
anext:
       mov qword [b],1                       ; initialize a,b,c as 1
bnext:
       mov qword [c],1                       ; initialize a,b,c as 1
cnext:
       call checkabc                         ; check if a^2+b^2=c^2
       cmp eax,0
       jne noprint
       lea rdi,[prnfmt]                      ; setting up read of one line fmt arg 1
       mov rsi,[a]                           ; a is arg2
       mov rdx,[b]                           ; a is arg3
       mov rcx,[c]                           ; a is arg4
       xor eax,eax                           ; no floating point args
       call printf                           ; print a line
noprint:
       mov rax,[maxint]                      ; load maxint in rax
       add qword [c],1                       ; increment c
       cmp qword [c],rax
       jle cnext
       add qword [b],1                       ; increment b
       cmp qword [b],rax
       jle bnext                             ; restart c loop
       add qword [a],1                       ; increment a
       cmp qword [a],rax
       jle anext                             ; restart b loop
       xor eax,eax                           ; return code 0
       leave                                 ; fix stack
       ret                                   ; return
checkabc:
; check if a^2+b^2=c^2 
       push rbp
       mov rbp,rsp
       mov rax,[a]                           ; load a
       mov rbx,[b]                           ; load b
       cmp rax,rbx
       jg .notequal                          ; skip cases where a > b to eliminate duplicates
       imul rax,rax                          ; square a
       imul rbx,rbx                          ; square b
       add rbx,rax                           ; a^2+b^2
       mov rax,[c]                           ; load c
       imul rax,rax                          ; square c
       cmp rax,rbx                           ; does a^2+b^2=c^2?
       jne .notequal
       xor rax,rax                           ; 0 if equal
       jmp .done
.notequal: 
       mov rax,1                             ; 1 if not equal
.done:
       leave
       ret
