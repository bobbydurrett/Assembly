    segment .text
    global start
start:
    mov eax,60
    mov edi,0
    syscall
    end     
