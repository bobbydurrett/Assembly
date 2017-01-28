; Integer version of slope. Two
; points. (x1,y1) and (x2,y2)
; Returns diffx=(x2-x1)
; and diffy = (y2-y1)
; Register rax has 1 if slope 
; is undefined which is dy==0.
    section .data
x1     dq 0
y1     dq 0
x2     dq 0
y2     dq 4
diffx  dq 0
diffy  dq 0
       section .text
       global start
start:
       xor rax,rax  ; set rax=0
       mov rcx,1    ; set rcx=1
       mov rbx,[x2] ; load x2 in rbx
       sub rbx,[x1] ; rbx contains x2-x1
       cmovz rax,rcx ; set rax=1 if x2-x1==0 
       mov [diffx],rbx ; save x2-x1 in dx
       mov rbx,[y2] ; load y2 in rbx 
       sub rbx,[y1] ; rbx contains y2-y1
       mov [diffy],rbx ; save y2-y1 in dy
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
