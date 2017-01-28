    section .data
a   dq 1
b   dq 0x10
c   dq -3
d   dq -20
    section .text
    global start
start:
    mov rax,[a]
    mov rbx,[b]
    mov rcx,[c]
    mov rdx,[d]
    add rax,rbx
    add rax,rcx
    add rax,rdx
; exit with return code 0
    mov eax,60
    mov edi,0
    syscall
    end
