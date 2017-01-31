; Three 64 item sets: a,b,c
    section .data
a      dq 0             
b      dq 0
c      dq 0
       section .text
       global start
start:
       bts qword [a],0   ; insert 0 into a
       bts qword [a],1   ; insert 1 into a
       bts qword [a],7   ; insert 7 into a
       bts qword [a],13  ; insert 13 into a
       bts qword [b],1   ; insert 1 into b
       bts qword [b],3   ; insert 3 into b
       bts qword [b],12  ; insert 12 into b
       mov rax,[a]       ; mov a union b into c
       or rax,[b]
       mov [c],rax
       mov rax,[a]       ; mov a intersect b into c
       and rax,[b]
       mov [c],rax
       mov rax,[b]       ; mov a - b into c
       not rax           ; a - b = a intersect not b
       and rax,[a]     
       mov [c],rax
       btr qword [c],7  ; remove 7 from c
; exit with return code 0
       mov eax,60
       mov edi,0
       syscall
       end
