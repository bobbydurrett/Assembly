    section .data
a       dw 1
b       dw 2
c       dw 3
d       dw 4
sum1    dq 0
sum2    dq 0
diff1   dq 0
diff2   dq 0
    section .text
    global start
start:
    movsx rax,word [a] ; load a
    movsx rbx,word [b] ; load b
; a+b
    mov rcx,rax        ; rcx will have sum
    add rcx,rbx        ; add b
    mov [sum1],rcx     ; store a+b
; a-b
    mov rcx,rax        ; rcx will have difference
    sub rcx,rbx        ; subtract b
    mov [diff1],rcx     ; store a-b
    movsx rax,word [c] ; load c
    movsx rbx,word [d] ; load d
; c+d
    mov rcx,rax        ; rcx will have sum
    add rcx,rbx        ; add d
    mov [sum2],rcx     ; store c+d
; c-d
    mov rcx,rax        ; rcx will have difference
    sub rcx,rbx        ; subtract d
    mov [diff2],rcx     ; store c-d
; exit with return code 0
    mov eax,60
    mov edi,0
    syscall
    end
