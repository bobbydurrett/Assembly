    section .data
a   db 1
b   dw 2
c   dd 3
d   dq 4
sum dq 0
    section .text
    global start
start:
    movsx rax,byte [a]
    movsx rbx,word [b]
    movsxd rcx,dword [c]
    mov rdx,[d]
    add rax,rbx
    add rax,rcx
    add rax,rdx
    mov [sum],rax
; exit with return code 0
    mov eax,60
    mov edi,0
    syscall
    end
