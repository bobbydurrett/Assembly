; greatest common divisor of two integers
; gcd(a,b) = a if b ==0
; gcd(a,b) = gcd(b,a mod b) if b <> 0
           segment .data
a          dq 0                                          
b          dq 0                                          
longscan   db "%ld",0                                    ; read long integer - qword
gcdab      dq 0                                          ; gcd of a and b
output     db "%ld",0x0a,0                               ; format to print elements
           segment .text
           global main
           global gcd
           extern scanf
           extern printf
main:
           push rbp
           mov rbp,rsp
           lea rdi,[longscan]                    ; read a number
           lea rsi,[a]                           ; read a
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
           lea rdi,[longscan]                    ; read a number
           lea rsi,[b]                           ; read b
           xor eax,eax                           ; no floating point args
           call scanf                            ; read a line
           mov rdi,[a]                           ; a and b arguments
           mov rsi,[b]
           call gcd
           mov [gcdab],rax                       ; gcd returned in rax
           lea rdi,[output]                      ; format to print a number on a line
           mov rsi,[gcdab]                       ; load gcd
           xor eax,eax                           ; no floating point args
           call printf                           ; print a line
           xor eax,eax                           ; return code 0
           leave                                 ; fix stack
           ret                                   ; return
gcd:
           push rbp
           mov rbp,rsp
           cmp rsi,0
           jne .recurse
           mov rax,rdi                            ; move a into rax to return
           jmp .done
.recurse:
           mov rax,rdi                            ; load a into rax
           xor rdx,rdx
           idiv rsi                               ; divide by b
           mov rdi,rsi                            ; move b into rdi
           mov rsi,rdx                            ; load a mod b into rsi for recursive call
           call gcd
.done:
           leave
           ret
