; Compute the distance squared between two
; points. (x1,y1) and (x2,y2)
; Since a^2+b^2=c^ for right triangle use
; (x2-x1)^2 + (y2-y1)^2
; output contains the answer
; I'm going to assume that the
; answer fits in 64 bits
; answer should be 25 
; 3-4-5 right triangle
    section .data
x1     dq 0
y1     dq 0
x2     dq 3
y2     dq 4
output dq 0
       section .text
       global start
start:
       mov rax,[x2]
       sub rax,[x1] ; rax contains x2-x1
       imul rax,rax ; rax contains (x2-x1)^2
       mov rbx,[y2] 
       sub rbx,[y1] ; rbx contains y2-y1
       imul rbx,rbx ; rbx contains (y2-y1)^2
       add rbx,rax  ; rbx contains answer
       mov [output],rbx ; save answer
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
